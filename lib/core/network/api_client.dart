// lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // <--- Añadir esto
import 'package:oppy2_frontend/core/network/api_config.dart';

// Definimos el storage como un provider independiente (buena práctica)
final storageProvider = Provider((ref) => const FlutterSecureStorage());

final apiClientProvider = Provider((ref) {
  final storage = ref.watch(storageProvider);
  return ApiClient(storage);
});

class ApiClient {
  late final Dio dio;
  final FlutterSecureStorage _storage;

  ApiClient(this._storage) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // INTERCEPTOR DE AUTENTICACIÓN
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // CAMBIAR 'auth_token' por 'access_token'
          final token = await _storage.read(key: 'access_token');
          
          if (token != null) {
            // Para debug, puedes dejar este print un momento:
            // print("DEBUG: Token inyectado correctamente en el header.");
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            print("DEBUG: OJO, no se encontró el token bajo la llave 'access_token'");
          }
          return handler.next(options);
        },
      ),
    );

    // Tu LogInterceptor para debug
    dio.interceptors.add(LogInterceptor(
      responseBody: true,
      requestBody: true,
    )); 
  }
}