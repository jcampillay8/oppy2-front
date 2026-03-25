// lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:oppy2_frontend/core/network/api_config.dart';

class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl, // Viene de tu config actual
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      ),
    );

    // Aquí podrías agregar interceptores para el Token JWT más adelante
    dio.interceptors.add(LogInterceptor(responseBody: true)); 
  }
}