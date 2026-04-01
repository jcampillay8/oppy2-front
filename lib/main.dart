// lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart' as legacy;
import 'package:app_links/app_links.dart';

// Importaciones de Core
import 'package:oppy2_frontend/core/theme/app_theme.dart';
import 'package:oppy2_frontend/core/network/api_client.dart';

// Importaciones de Features (Auth)
import 'package:oppy2_frontend/features/auth/providers/auth_provider.dart';
import 'package:oppy2_frontend/features/auth/services/auth_service.dart';
import 'package:oppy2_frontend/features/auth/screens/welcome_screen.dart';

// Importaciones de Features (Home)
import 'package:oppy2_frontend/features/home/screens/home_screen.dart';
import 'package:oppy2_frontend/features/onboarding/screens/onboarding_screen.dart';

// Importaciones de Features (Test)
import 'package:oppy2_frontend/features/placement_test/providers/writing_test_provider.dart'; 
import 'package:oppy2_frontend/features/placement_test/screens/writing_test_screen.dart';
import 'package:oppy2_frontend/features/placement_test/screens/language_selection_screen.dart';
import 'package:oppy2_frontend/features/placement_test/screens/test_intro_screen.dart';
import 'package:oppy2_frontend/features/placement_test/screens/reading_test_screen.dart';
import 'package:oppy2_frontend/features/placement_test/screens/listening_test_screen.dart';
import 'package:oppy2_frontend/features/placement_test/screens/speaking_test_screen.dart';
import 'package:oppy2_frontend/features/placement_test/screens/analyzing_results_screen.dart';
import 'package:oppy2_frontend/features/placement_test/screens/test_results_screen.dart';
import 'package:oppy2_frontend/features/placement_test/services/placement_test_service.dart';

void main() {
  runApp(
    const ProviderScope(
      child: OppyAppWrapper(),
    ),
  );
}

class OppyAppWrapper extends StatelessWidget {
  const OppyAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Instanciamos el ApiClient una sola vez
    final apiClient = ApiClient(const FlutterSecureStorage());

    return legacy.MultiProvider(
      providers: [
        legacy.ChangeNotifierProvider(create: (_) => AuthProvider()),
        // INYECCIÓN CLAVE:
        legacy.Provider<PlacementTestService>(
          create: (_) => PlacementTestService(apiClient),
        ),
      ],
      child: const OppyApp(),
    );
  }
}

class OppyApp extends StatefulWidget {
  const OppyApp({super.key});
  @override
  State<OppyApp> createState() => _OppyAppState();
}

class _OppyAppState extends State<OppyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  final AuthService _authService = AuthService(ApiClient(const FlutterSecureStorage()));

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  // --- LÓGICA DE DEEP LINKS ---
  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
      debugPrint("Link capturado (Stream): $uri");
      _processLink(uri);
    }, onError: (err) {
      debugPrint("Error en el stream de Deep Links: $err");
    });

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
    if (uri.scheme == 'oppychat' && uri.host == 'confirm-success') {
      _handleSuccessView();
      return;
    }
    if (uri.pathSegments.contains('confirm-email')) {
      final token = uri.pathSegments.last;
      _confirmAccount(token);
    }
  }

  void _handleSuccessView() {
    if (!mounted) return;
    final context = _navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🚀 ¡Email verificado! Ya puedes iniciar sesión."),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _navigatorKey.currentState?.pushNamedAndRemoveUntil('/welcome', (route) => false);
    }
  }

  Future<void> _confirmAccount(String token) async {
    final success = await _authService.confirmEmail(token);
    if (success && mounted) {
      _handleSuccessView();
    }
  }

  // --- SOLO UN DISPOSE AQUÍ ---
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
      home: legacy.Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.status != AuthStatus.authenticated) {
            return const WelcomeScreen();
          }

          return FutureBuilder<Map<String, dynamic>?>(
            future: _authService.checkNavigationFlow(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: Color(0xFF0F172A),
                  body: Center(child: CircularProgressIndicator(color: Colors.blue)),
                );
              }

              final data = snapshot.data ?? {};
              final bool hasTest = data['has_test'] ?? false;
              final int currentStep = data['current_step'] ?? 1;

              if (currentStep < 4) {
                return OnboardingScreen(initialStep: currentStep);
              }

              if (!hasTest) {
                return const LanguageSelectionScreen();
              }

              return const HomeScreen();
            },
          );
        },
      ),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/home': (context) => const HomeScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/select-language': (context) => const LanguageSelectionScreen(), 
        '/test-diagnostico': (context) => const TestIntroScreen(),      
        '/writing-test': (context) => const WritingTestScreen(),
        '/reading-test': (context) => const ReadingTestScreen(),
        '/listening-test': (context) => const ListeningTestScreen(),
        '/speaking-test': (context) => const SpeakingTestScreen(),
        '/analyzing-test': (context) => const AnalyzingResultsScreen(),
        '/test-results': (context) => const TestResultsScreen(),
      },
    );
  }
}