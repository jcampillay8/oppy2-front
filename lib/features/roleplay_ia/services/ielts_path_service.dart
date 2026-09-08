import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/learning_path_model.dart';

class IeltsPathService {
  final ApiClient _apiClient;
  IeltsPathService(this._apiClient);

  Future<List<LearningPathUnitProgress>> getProgress() async {
    try {
      final response = await _apiClient.dio.get('/learning-analysis/ielts-path/progress');
      final list = response.data['progress'] as List;
      return list.map((e) => LearningPathUnitProgress.fromJson(e)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getSyllabus() async {
    try {
      final response = await _apiClient.dio.get('/learning-analysis/ielts-path/syllabus');
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getActivityStats() async {
    try {
      final response = await _apiClient.dio.get('/learning-analysis/ielts-path/activity');
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> translateWithDeepL(String text, String targetLang) async {
    try {
      final response = await _apiClient.dio.post(
        '/learning-analysis/deepl/translate',
        data: {'text': text, 'targetLang': targetLang},
      );
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getUnitContent(int level, int unit) async {
    try {
      final response = await _apiClient.dio.get(
        '/learning-analysis/ielts-path/content',
        queryParameters: {'level': level, 'unit': unit},
      );
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> generateChallenge(int level, int unit) async {
    try {
      final response = await _apiClient.dio.get(
        '/learning-analysis/ielts-path/challenge/generate',
        queryParameters: {'level': level, 'unit': unit},
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<UnitCompleteResponse> completeUnit(int level, int unit, double precisionScore) async {
    try {
      final response = await _apiClient.dio.post(
        '/learning-analysis/ielts-path/session/complete',
        data: {
          'level': level,
          'unit': unit,
          'precision_score': precisionScore,
        },
      );
      return UnitCompleteResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  dynamic _handleError(dynamic e) {
    if (e is DioException) {
      return e.response?.data['detail'] ?? "Error de servidor";
    }
    return e.toString();
  }
}

final ieltsPathServiceProvider = Provider<IeltsPathService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return IeltsPathService(apiClient);
});
