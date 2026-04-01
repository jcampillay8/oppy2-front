// lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oppy2_frontend/core/network/api_config.dart';

// Provider de storage (para usarlo en el resto de la app con Riverpod)
final storageProvider = Provider((ref) => const FlutterSecureStorage());

// Provider del ApiClient
final apiClientProvider = Provider((ref) {
  final storage = ref.watch(storageProvider);
  return ApiClient(storage);
});

class ApiClient {
  late final Dio dio;
  final FlutterSecureStorage _storage;

  // Getter para que AuthService pueda hacer: _apiClient.storage
  FlutterSecureStorage get storage => _storage;

  ApiClient(this._storage) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10), // Un poco más de tiempo para el backend
        receiveTimeout: const Duration(seconds: 10),
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
          final token = await _storage.read(key: 'access_token');
          
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            print("DEBUG: Token expirado o inválido (401)");
          }
          return handler.next(e);
        },
      ),
    );

    // LogInterceptor para ver qué pasa en la consola
    dio.interceptors.add(LogInterceptor(
      responseBody: true,
      requestBody: true,
    )); 
  }
}