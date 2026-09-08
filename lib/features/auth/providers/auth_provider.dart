// lib/features/auth/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:oppy2_frontend/features/auth/services/auth_service.dart';
import 'package:oppy2_frontend/core/shared_models/user_model.dart';

enum AuthStatus { authenticated, unauthenticated, authenticating, emailConfirmed, error }

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  AuthProvider(this._authService);

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: kIsWeb ? null : "234259540741-hv5m3meib6pav7qsufbb8lpku5eto7ft.apps.googleusercontent.com",
    scopes: ['email', 'profile'],
  );

  AuthStatus _status = AuthStatus.unauthenticated;
  UserModel? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String username, String password) async {
    _setAuthenticating();
    try {
      final success = await _authService.login(username, password);
      if (success) {
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      _setUnauthenticated("Credenciales incorrectas.");
      return false;
    } catch (e) {
      _setUnauthenticated("Error de conexión.");
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    _setAuthenticating();
    try {
      final success = await _authService.register(email, password);
      if (success) {
        _status = AuthStatus.unauthenticated;
        _errorMessage = "Verifica tu email.";
        notifyListeners();
        return true;
      } else {
        _setUnauthenticated("El registro falló.");
        return false;
      }
    } catch (e) {
      _setUnauthenticated("Error en el registro.");
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    _setAuthenticating();
    try {
      await _googleSignIn.signOut();
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }

      final googleAuth = await googleUser.authentication;
      String? tokenParaBackend = googleAuth.idToken ?? googleAuth.accessToken;

      if (kIsWeb && tokenParaBackend == null) {
        final auth = await googleUser.authentication;
        tokenParaBackend = auth.idToken ?? auth.accessToken;
      }

      if (tokenParaBackend != null) {
        final success = await _authService.signInWithGoogle(tokenParaBackend);
        if (success) {
          _status = AuthStatus.authenticated;
          notifyListeners();
          return true;
        }
      } else {
        if (kIsWeb) {
          print("CONSEJO WEB: Revisa el index.html y que el puerto sea el 5000.");
        }
      }

      _setUnauthenticated("No se pudo sincronizar con Google.");
      return false;
    } catch (e) {
      print("DEBUG: Error fatal en loginWithGoogle: $e");
      _setUnauthenticated("Error de Google: $e");
      return false;
    }
  }

  void _setAuthenticating() {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();
  }

  void _setUnauthenticated(String message) {
    _status = AuthStatus.unauthenticated;
    _errorMessage = message;
    notifyListeners();
  }

  void markEmailAsConfirmed() {
    _status = AuthStatus.emailConfirmed;
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      await _authService.logout();
    } catch (e) {
      print("Error durante el logout: $e");
    } finally {
      _status = AuthStatus.unauthenticated;
      _user = null;
      notifyListeners();
    }
  }
}
