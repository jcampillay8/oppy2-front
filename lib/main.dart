// lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';

// Importaciones de Core
import 'package:oppy2_frontend/core/theme/app_theme.dart';

// Importaciones de Features (Auth)
import 'package:oppy2_frontend/features/auth/providers/auth_provider.dart';
import 'package:oppy2_frontend/features/auth/services/auth_service.dart';
import 'package:oppy2_frontend/features/auth/screens/welcome_screen.dart';

// Importaciones de Features (Home)
import 'package:oppy2_frontend/features/home/screens/home_screen.dart';
import 'package:oppy2_frontend/features/onboarding/screens/onboarding_screen.dart';
// Busca la sección de imports y agrega esta línea:
import 'package:oppy2_frontend/features/placement_test/providers/placement_test_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PlacementTestProvider()),
      ],
      child: const OppyApp(),
    ),
  );
}

class OppyApp extends StatefulWidget {
  const OppyApp({super.key});

  @override
  State<OppyApp> createState() => _OppyAppState();
}

class _OppyAppState extends State<OppyApp> {
  // NavigatorKey nos permite navegar desde fuera del build (como en el callback de Deep Links)
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  // --- LÓGICA DE DEEP LINKS ---
  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // 1. Escuchar links entrantes (App en segundo plano o abierta)
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
      debugPrint("Link capturado (Stream): $uri");
      _processLink(uri);
    }, onError: (err) {
      debugPrint("Error en el stream de Deep Links: $err");
    });

    // 2. Revisar inicio desde cero (Cold Start)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint("Link inicial capturado (Cold Start): $initialUri");
        _processLink(initialUri);
      }
    } catch (e) {
      debugPrint("Error al recuperar el link inicial: $e");
    }
  }

  void _processLink(Uri uri) {
    // Caso A: El link viene directo del backend (Redirección Exitosa)
    // URL: oppychat://confirm-success?token=...
    if (uri.scheme == 'oppychat' && uri.host == 'confirm-success') {
      debugPrint("Confirmación exitosa detectada. Redirigiendo...");
      _handleSuccessView();
      return;
    }

    // Caso B: El link es HTTP (Captura directa antes de la redirección)
    if (uri.pathSegments.contains('confirm-email')) {
      final token = uri.pathSegments.last;
      debugPrint("Token HTTP extraído para confirmación manual: $token");
      _confirmAccount(token);
    }
  }

  // Esta función se activa cuando el backend ya confirmó al usuario
  void _handleSuccessView() {
    if (!mounted) return;

    // 1. Feedback visual (SnackBar)
    // Usamos el contexto de navegación para asegurar que el SnackBar aparezca
    final context = _navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🚀 ¡Email verificado! Ya puedes iniciar sesión."),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
        ),
      );

      // 2. NAVEGACIÓN FORZADA:
      // Esto "limpia" la pantalla de registro y te lleva al Welcome (donde está el Login)
      // Asegura que el formulario que ves en tu imagen se cierre.
      _navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/welcome', 
        (route) => false,
      );
    }
  }

  // Solo se usa si el Deep Link falla y tenemos que llamar al backend manualmente
  Future<void> _confirmAccount(String token) async {
    final success = await _authService.confirmEmail(token);
    if (success && mounted) {
      _handleSuccessView();
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

@override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'OppyChat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          // 1. Si NO está autenticado, directo al Welcome
          if (auth.status != AuthStatus.authenticated) {
            return const WelcomeScreen();
          }

          // 2. Si ESTÁ autenticado, consultamos el flujo al Backend
          return FutureBuilder<Map<String, dynamic>?>(
            future: _authService.checkNavigationFlow(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: AppColors.backgroundDark,
                  body: Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
                );
              }

              // Si hay error o no hay datos, por seguridad al inicio del onboarding
              if (snapshot.hasError || !snapshot.hasData) {
                return const OnboardingScreen(initialStep: 1);
              }

              final data = snapshot.data!;
              final String? occupation = data['occupation'];
              final String? bio = data['bio'];
              final bool hasTest = data['has_test'] ?? false;
              final int currentStep = data['current_step'] ?? 1;

              // FILTRO 1: ¿Faltan datos de perfil? (Nombre, Ocupación o Bio)
              if (currentStep < 4) {
                return OnboardingScreen(initialStep: currentStep);
              }

              // FILTRO 2: ¿Falta el test diagnóstico?
              if (!hasTest) {
                return const OnboardingScreen(initialStep: 4); 
              }

              // Si pasó ambos filtros, bienvenido al Home
              return const HomeScreen();
            }, // Cierre builder FutureBuilder
          );
        }, // Cierre builder Consumer
      ),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/home': (context) => const HomeScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        // '/test-diagnostico': (context) => const PlacementTestScreen(), 
      },
    );
  }
}