// lib/features/auth/services/auth_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oppy2_frontend/core/network/api_client.dart';
import 'package:oppy2_frontend/core/network/api_config.dart';

// Definimos el provider para que otras partes de la app puedan usar AuthService
final authServiceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(apiClient);
});

class AuthService {
  // Ahora usamos el ApiClient centralizado
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  // --- ACTUALIZAR IDIOMA DEL TEST ---
  Future<bool> updateTargetLanguage(String langCode) async {
    try {
      // El interceptor de _apiClient pondrá el Token automáticamente
      final response = await _apiClient.dio.post(
        '/onboarding/select-language', 
        data: {"target_language": langCode},
      );
      return response.statusCode == 200;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  // --- CONSULTAR FLUJO DE NAVEGACIÓN ---
  Future<Map<String, dynamic>?> checkNavigationFlow() async {
    try {
      final response = await _apiClient.dio.get('/onboarding/status');
      return response.statusCode == 200 ? response.data : null;
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  // --- ACTUALIZAR PERFIL ---
  Future<bool> updateOnboardingProfile({
    String? username,
    String? occupation,
    String? bio,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (username != null && username.trim().isNotEmpty) data['username'] = username.trim();
      if (occupation != null && occupation.trim().isNotEmpty) data['occupation'] = occupation.trim();
      if (bio != null && bio.trim().isNotEmpty) data['bio'] = bio.trim();

      final response = await _apiClient.dio.patch(
        '/onboarding/update-profile',
        data: data,
      );
      return response.statusCode == 200;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  // --- REGISTRO ---
  Future<bool> register(String email, String password) async {
    try {
      final tempUsername = email.split("@")[0].toLowerCase();
      final formData = FormData.fromMap({
        "email": email,
        "username": tempUsername,
        "password": password,
        "first_name": "",
        "last_name": "",
        "terms_accepted": true,
      });
      final response = await _apiClient.dio.post(ApiConfig.register, data: formData);
      return response.statusCode != null && response.statusCode! < 300;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  // --- CONFIRMACIÓN DE EMAIL ---
  Future<bool> confirmEmail(String token) async {
    try {
      // Usamos el endpoint relativo si ApiConfig.baseUrl está bien seteado
      final response = await _apiClient.dio.get('/confirm-email/$token');
      return response.statusCode == 200 || response.statusCode == 307;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  // --- LOGIN ---
  Future<bool> login(String username, String password) async {
    try {
      final formData = FormData.fromMap({"username": username, "password": password});
      final response = await _apiClient.dio.post(ApiConfig.login, data: formData);

      if (response.statusCode == 200) {
        final accessToken = response.data['accessToken'];   // ← camelCase
        // El backend JWT no devuelve refresh_token, lo incluye todo en accessToken
        
        if (accessToken != null) {
          await _apiClient.storage.write(key: 'access_token', value: accessToken);
          debugPrint("DEBUG: Tokens guardados exitosamente.");
          return true;
        }
      }
      return false;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  // --- GOOGLE SIGN IN ---
  Future<bool> signInWithGoogle(String idToken) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.googleMobileSignin, 
        data: {"id_token": idToken}
      );

      if (response.statusCode == 200) {
        final accessToken = response.data['access_token'];
        final refreshToken = response.data['refresh_token'];
        if (accessToken != null) {
          await _apiClient.storage.write(key: 'access_token', value: accessToken);
          await _apiClient.storage.write(key: 'refresh_token', value: refreshToken);
          return true;
        }
      }
      return false;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    await _apiClient.storage.deleteAll();
    // No necesitamos limpiar headers manualmente, el interceptor verá que no hay token
  }

  void _handleError(dynamic e) {
    if (e is DioException) {
      debugPrint("--- Error Backend OppyChat ---");
      debugPrint("Status: ${e.response?.statusCode}");
      debugPrint("Data: ${e.response?.data}");
    } else {
      debugPrint("Error Inesperado: $e");
    }
  }
}