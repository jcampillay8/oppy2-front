import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';
import 'package:oppy2_frontend/core/app_theme.dart';
import 'package:oppy2_frontend/screens/welcome_screen.dart';
import 'package:oppy2_frontend/screens/home_screen.dart';
import 'package:oppy2_frontend/providers/auth_provider.dart';
import 'package:oppy2_frontend/services/auth_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
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
      navigatorKey: _navigatorKey, // Asignamos la llave aquí
      title: 'OppyChat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.status == AuthStatus.authenticated) {
            return const HomeScreen();
          }
          return const WelcomeScreen();
        },
      ),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}