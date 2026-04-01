// lib/features/auth/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oppy2_frontend/features/auth/services/auth_service.dart';
import 'package:oppy2_frontend/core/shared_models/user_model.dart';
import 'package:oppy2_frontend/core/network/api_client.dart';

enum AuthStatus { authenticated, unauthenticated, authenticating, emailConfirmed, error }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService(ApiClient(const FlutterSecureStorage()));
  
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // ✅ COPIA Y PEGA EL ID DEL JSON WEB AQUÍ:
    serverClientId: "234259540741-hv5m3meib6pav7qsufbb8lpku5eto7ft.apps.googleusercontent.com",
    scopes: ['email', 'profile'],
  );
  
  AuthStatus _status = AuthStatus.unauthenticated;
  UserModel? _user;
  String? _errorMessage;

  // Getters
  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;

  // --- 1. LOGIN MANUAL ---
  Future<bool> login(String username, String password) async {
    _setAuthenticating();
    try {
      final success = await _authService.login(username, password);
      if (success) {
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _setUnauthenticated("Credenciales incorrectas.");
        return false;
      }
    } catch (e) {
      _setUnauthenticated("Error de conexión.");
      return false;
    }
  }

  // --- 2. REGISTRO MANUAL ---
  Future<bool> register(String email, String password, String username) async {
    _setAuthenticating();
    try {
      final success = await _authService.register(email, password, username);
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

  // --- 3. GOOGLE OAUTH2 ---
  Future<bool> loginWithGoogle() async {
    _setAuthenticating();
    try {
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print("DEBUG: El usuario cerró la ventana de Google.");
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      // ✅ AJUSTE: Corregida la sintaxis del print para evitar errores de compilación
      if (idToken != null) {
        print("DEBUG: idToken obtenido correctamente.");
        print("DEBUG: Enviando token al backend OppyChat...");
        
        final bool success = await _authService.signInWithGoogle(idToken);
        
        if (success) {
          // 1. Antes de cambiar el estado, obtenemos el perfil fresco
          final userData = await _authService.checkNavigationFlow();
          
          if (userData != null) {
            // Si tienes un modelo de usuario, cárgalo aquí
            // _user = UserModel.fromJson(userData); 
            
            // 2. Ahora sí, cambiamos el estado
            _status = AuthStatus.authenticated;
            notifyListeners();
            return true;
          }
        }
      } else {
        print("DEBUG: idToken es NULL. Revisa el serverClientId.");
      }
      
      _setUnauthenticated("Error al sincronizar con Google o token nulo.");
      return false;
    } catch (e) {
      print("DEBUG: Error fatal en loginWithGoogle: $e");
      _setUnauthenticated("Error de Google: $e");
      return false;
    }
  }

  // --- Helpers ---
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