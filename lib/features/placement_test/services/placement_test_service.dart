// lib/features/placement_test/services/placement_test_service.dart
import 'package:oppy2_frontend/core/network/api_client.dart';
import '../models/writing_models.dart';

class PlacementTestService {
  final ApiClient _apiClient;

  PlacementTestService(this._apiClient);

  /// Obtiene la pregunta de Writing desde el backend
  Future<WritingQuestion> getQuestion() async {
    try {
      final response = await _apiClient.dio.get('/onboarding/writing/question');
      
      if (response.data != null) {
        return WritingQuestion.fromJson(response.data);
      } else {
        throw Exception("No se recibió información de la pregunta.");
      }
    } catch (e) {
      rethrow; 
    }
  }

  /// Envía la respuesta para ser evaluada por la IA
  Future<Map<String, dynamic>> evaluateWriting(String answer, String lang) async {
    try {
      // Print para verificar en consola antes de que salga el request
      print("DEBUG: Enviando a evaluación -> Idioma: $lang, Longitud: ${answer.length}");

      final response = await _apiClient.dio.post(
        '/onboarding/writing/evaluate', 
        data: {
          'user_answer': answer,    // Contenido del texto largo
          'target_language': lang,  // 'en' o 'es'
        },
      );
      
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}