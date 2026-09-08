// lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oppy2_frontend/core/network/api_config.dart';

final storageProvider = Provider((ref) => const FlutterSecureStorage());

final apiClientProvider = Provider((ref) {
  final storage = ref.watch(storageProvider);
  return ApiClient(storage);
});

class ApiClient {
  late final Dio dio;
  final FlutterSecureStorage _storage;

  FlutterSecureStorage get storage => _storage;

  ApiClient(this._storage) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 5),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // UN SOLO INTERCEPTOR DE AUTENTICACIÓN (Limpio y robusto)
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 1. Definir rutas que NO necesitan token
          final publicPaths = ['/login', '/register', '/confirm-email'];
          final isPublic = publicPaths.any((path) => options.path.contains(path));

          if (isPublic) {
            debugPrint("DEBUG: [${options.method}] Ruta pública: ${options.path}");
            return handler.next(options);
          }

          // 2. Intentar leer el token
          final token = await _storage.read(key: 'access_token');
          
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            debugPrint("DEBUG: [${options.method}] Token inyectado en: ${options.path}");
          } else {
            debugPrint("DEBUG: [${options.method}] ADVERTENCIA: No hay token para ${options.path}");
          }
          
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            debugPrint("DEBUG: [401] No autorizado en ${e.requestOptions.path}");
          }
          return handler.next(e);
        },
      ),
    );

    // INTERCEPTOR DE LOGS (Solo en modo debug para evitar fuga de tokens)
    assert(
      () {
        dio.interceptors.add(LogInterceptor(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
        ));
        return true;
      }(),
    );
  }
}