// lib/features/auth/services/auth_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart'; // Para debugPrint
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oppy2_frontend/core/network/api_config.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
    followRedirects: false, 
    validateStatus: (status) => status! < 500,
  ));

  final _storage = const FlutterSecureStorage();

  // --- NUEVO: ACTUALIZAR IDIOMA DEL TEST ---
  Future<bool> updateTargetLanguage(String langCode) async {
    try {
      // AGREGAMOS /onboarding ANTES DE /select-language
      final String url = ApiConfig.getFullUrl('/onboarding/select-language'); 
      
      final token = await _storage.read(key: 'access_token');
      if (token == null) return false;

      final response = await _dio.post(
        url,
        data: {
          "target_language": langCode,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
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
      final String url = ApiConfig.getFullUrl('/onboarding/status');
      final token = await _storage.read(key: 'access_token');
      
      if (token == null) return null;

      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data; 
      }
      return null;
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  // --- ACTUALIZAR PERFIL (Vistas 1, 2 y 3) ---
  Future<bool> updateOnboardingProfile({
    required String username,
    required String occupation,
    required String bio,
  }) async {
    try {
      final String url = ApiConfig.getFullUrl('/onboarding/update-profile');
      final token = await _storage.read(key: 'access_token');

      final response = await _dio.patch(
        url,
        data: {
          "username": username,
          "occupation": occupation,
          "bio": bio,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.statusCode == 200;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  // --- REGISTRO ---
  Future<bool> register(String email, String password, String username) async {
    try {
      final String url = ApiConfig.getFullUrl(ApiConfig.register); 
      final formData = FormData.fromMap({
        "email": email,
        "username": username,
        "password": password,
        "first_name": "Jaime",
        "last_name": "Campillay",
        "terms_accepted": true, 
      });
      final response = await _dio.post(url, data: formData);
      return response.statusCode != null && response.statusCode! < 300;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  // --- CONFIRMACIÓN DE EMAIL ---
  Future<bool> confirmEmail(String token) async {
    try {
      final String url = "${ApiConfig.baseUrl}/confirm-email/$token";
      final response = await _dio.get(url, options: Options(followRedirects: false, validateStatus: (status) => status! < 400));
      return response.statusCode == 200 || response.statusCode == 307;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  // --- LOGIN ---
  Future<bool> login(String username, String password) async {
    try {
      final String url = ApiConfig.getFullUrl(ApiConfig.login);
      final formData = FormData.fromMap({"username": username, "password": password});
      final response = await _dio.post(url, data: formData);

      if (response.statusCode == 200) {
        final accessToken = response.data['access_token'];
        final refreshToken = response.data['refresh_token'];
        await _storage.write(key: 'access_token', value: accessToken);
        await _storage.write(key: 'refresh_token', value: refreshToken);
        
        _dio.options.headers['Authorization'] = 'Bearer $accessToken';
        return true;
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
      final String url = ApiConfig.getFullUrl(ApiConfig.googleMobileSignin); 
      final response = await _dio.post(url, data: {"id_token": idToken}, options: Options(contentType: Headers.jsonContentType));

      if (response.statusCode == 200) {
        final accessToken = response.data['access_token'];
        final refreshToken = response.data['refresh_token'];
        if (accessToken != null) {
          await _storage.write(key: 'access_token', value: accessToken);
          await _storage.write(key: 'refresh_token', value: refreshToken);
          _dio.options.headers['Authorization'] = 'Bearer $accessToken';
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
    await _storage.deleteAll();
    _dio.options.headers.remove('Authorization');
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