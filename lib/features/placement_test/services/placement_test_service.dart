// lib/features/placement_test/services/placement_test_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../models/writing_topic_model.dart';

class PlacementTestService {
  final ApiClient _apiClient = ApiClient();

  /// 1. Obtener el tema asignado o uno nuevo (PASO 1)
  /// Endpoint: POST /onboarding/writing/setup
  Future<WritingTopic> getWritingTopic({
    required String category,
    required String language,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/onboarding/writing/setup',
        data: {
          'category': category,
          'target_language': language,
        },
      );

      if (response.statusCode == 200) {
        return WritingTopic.fromJson(response.data);
      } else {
        throw Exception('Error al obtener el tema de escritura');
      }
    } on DioException catch (e) {
      debugPrint("DioError en setup: ${e.response?.data ?? e.message}");
      rethrow;
    }
  }

  /// 2. Enviar el texto para evaluación por IA (PASO 2)
  /// Endpoint: POST /onboarding/writing/evaluate
  Future<double> evaluateWriting({
    required String text,
    required String language,
  }) async {
    try {
      // 💡 TIP: Sobreescribimos el timeout a 45 segundos solo para esta llamada,
      // ya que Gemini analizando gramática y vocabulario puede demorar.
      final response = await _apiClient.dio.post(
        '/onboarding/writing/evaluate',
        data: {
          'text': text,
          'target_language': language,
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 45), 
        ),
      );

      if (response.statusCode == 200) {
        // Tu backend devuelve: {"status": "success", "score": float}
        return (response.data['score'] as num).toDouble();
      } else {
        throw Exception('Error en la evaluación de la IA');
      }
    } on DioException catch (e) {
      debugPrint("DioError en evaluate: ${e.response?.data ?? e.message}");
      rethrow;
    }
  }
}