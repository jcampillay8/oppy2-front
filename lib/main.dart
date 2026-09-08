// lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy;
import 'package:app_links/app_links.dart';

// Importaciones de Core
import 'package:oppy2_frontend/core/theme/app_theme.dart';
import 'package:oppy2_frontend/core/network/api_client.dart';

// Importaciones de Features (Auth)
import 'package:oppy2_frontend/features/auth/providers/auth_provider.dart';
import 'package:oppy2_frontend/features/auth/services/auth_service.dart';
import 'package:oppy2_frontend/features/auth/screens/welcome_screen.dart';

// Importaciones Minimalistas (Profile & Tutor)
import 'package:oppy2_frontend/features/profile/screens/profile_screen.dart';
import 'package:oppy2_frontend/features/roleplay_ia/screens/main_menu_screen.dart';
import 'package:oppy2_frontend/features/roleplay_ia/screens/tutor_selection_screen.dart';
import 'package:oppy2_frontend/features/roleplay_ia/screens/chat_view_screen.dart';
import 'package:oppy2_frontend/features/roleplay_ia/models/avatar_model.dart';
import 'package:oppy2_frontend/features/roleplay_ia/screens/avatar_editor_screen.dart';
import 'package:oppy2_frontend/features/roleplay_ia/screens/vocabulary_practice_screen.dart';
import 'package:oppy2_frontend/features/roleplay_ia/screens/ielts_learning_path_screen.dart';
import 'package:oppy2_frontend/features/roleplay_ia/screens/ielts_listening_path_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: OppyAppWrapper(),
    ),
  );
}

class OppyAppWrapper extends ConsumerWidget {
  const OppyAppWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);

    return legacy.MultiProvider(
      providers: [
        legacy.ChangeNotifierProvider(
          create: (_) => AuthProvider(authService),
        ),
      ],
      child: const OppyApp(),
    );
  }
}

class OppyApp extends ConsumerStatefulWidget {
  const OppyApp({super.key});
  @override
  ConsumerState<OppyApp> createState() => _OppyAppState();
}

class _OppyAppState extends ConsumerState<OppyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

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
    final authService = ref.read(authServiceProvider);
    final success = await authService.confirmEmail(token);
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
      title: 'OppyChat Tutor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: legacy.Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.status == AuthStatus.authenticated) {
            return const MainMenuScreen();
          } else {
            return const WelcomeScreen();
          }
        },
      ),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/home': (context) => const MainMenuScreen(),
        '/tutor-selection': (context) => const TutorSelectionScreen(),
        '/vocabulary-practice': (context) => const VocabularyPracticeScreen(),
        '/ielts-path': (context) => const IeltsLearningPathScreen(),
        '/ielts-listening-path': (context) => const IeltsListeningPathScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/avatar-editor': (context) => const AvatarEditorScreen(),
        '/chat-view': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is AvatarModel) {
            return ChatViewScreen(avatar: args);
          }
          return const Scaffold(body: Center(child: Text("Error: Tutor no encontrado")));
        },
      },
    );
  }
}