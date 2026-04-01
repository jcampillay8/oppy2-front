// lib/features/placement_test/services/placement_test_service.dart
import 'package:dio/dio.dart';
import 'package:oppy2_frontend/core/network/api_client.dart';
import '../models/writing_models.dart';

class PlacementTestService {
  final ApiClient _apiClient;

  PlacementTestService(this._apiClient);

  /// Obtiene la pregunta de Writing desde el backend.
  Future<WritingQuestion> getQuestion() async {
    try {
      final response = await _apiClient.dio.get('/onboarding/writing/question');
      return WritingQuestion.fromJson(response.data);
    } catch (e) {
      rethrow; 
    }
  }

  /// Envía la respuesta de Writing para su evaluación.
  Future<Map<String, dynamic>> evaluateWriting(String answer, String lang) async {
    try {
      final response = await _apiClient.dio.post(
        '/onboarding/writing/evaluate', 
        data: {'user_answer': answer, 'target_language': lang},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Sube el archivo de audio y recibe la evaluación específica de Speaking.
  Future<Map<String, dynamic>> evaluateSpeaking(String filePath) async {
    try {
      // El nombre "audio_file" coincide con el parámetro UploadFile del backend.
      FormData formData = FormData.fromMap({
        "audio_file": await MultipartFile.fromFile(
          filePath,
          filename: "speaking_test.m4a",
        ),
      });

      final response = await _apiClient.dio.post(
        '/onboarding/speaking/evaluate', 
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      print("Error en evaluateSpeaking: $e");
      rethrow;
    }
  }

  /// ESTA ES LA MEJORA CLAVE:
  /// Obtiene el objeto consolidado final (globalLevel, scores de las 4 áreas, 
  /// y el análisis narrativo de Oppy) que espera la pantalla de resultados.
  Future<Map<String, dynamic>> getFinalStatus() async {
    try {
      final response = await _apiClient.dio.get('/onboarding/final-status');
      
      // Este JSON contiene: global_level, level_name, scores, ai_analysis, etc.
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print("Error en getFinalStatus: $e");
      rethrow;
    }
  }
}