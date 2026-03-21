// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

// 1. Añadimos el estado 'emailConfirmed' para el feedback visual
enum AuthStatus { authenticated, unauthenticated, authenticating, emailConfirmed, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AuthStatus _status = AuthStatus.unauthenticated;
  UserModel? _user;
  String? _errorMessage;

  // Getters
  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;

  // --- NUEVO: Método para el Deep Link de main.dart ---
  // Esto permitirá que la UI reaccione cuando el usuario confirme su correo
  void markEmailAsConfirmed() {
    _status = AuthStatus.emailConfirmed;
    _errorMessage = null;
    notifyListeners(); 
  }

  // --- 1. LOGIN CON JWT (Botón "Iniciar Sesión") ---
  Future<bool> login(String username, String password) async {
    _setAuthenticating();

    try {
      final success = await _authService.login(username, password);

      if (success) {
        // CAMBIO CRÍTICO: Aseguramos que el estado cambie a authenticated
        _status = AuthStatus.authenticated;
        
        // TODO: Cargar el perfil del usuario desde Neon
        // _user = await _authService.getUserProfile();
        
        notifyListeners(); // Esto disparará el Consumer en main.dart y mostrará el HomeScreen
        return true;
      } else {
        _setUnauthenticated("Credenciales incorrectas o cuenta no activa.");
        return false;
      }
    } catch (e) {
      _setUnauthenticated("Error de conexión con el servidor.");
      return false;
    }
  }

  // --- 2. REGISTRO ---
  Future<bool> register(String email, String password, String username) async {
    _setAuthenticating();

    final success = await _authService.register(email, password, username);

    if (success) {
      // Importante: No hacemos login automático si el backend requiere 
      // confirmación de email, porque el login daría 401 hasta que confirme.
      _status = AuthStatus.unauthenticated; 
      _errorMessage = "Registro exitoso. Por favor verifica tu email.";
      notifyListeners();
      return true;
    } else {
      _setUnauthenticated("El registro falló. ¿Quizás el email ya existe?");
      return false;
    }
  }

  // --- 3. GOOGLE OAUTH2 ---
  Future<bool> loginWithGoogle() async {
    _setAuthenticating();
    
    final success = await _authService.signInWithGoogle();

    if (success) {
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _setUnauthenticated("Error con la cuenta de Google.");
      return false;
    }
  }

  // --- Métodos de Ayuda Internos ---
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

  Future<void> logout() async {
    await _authService.logout(); 
    _status = AuthStatus.unauthenticated;
    _user = null;
    notifyListeners();
  }
}