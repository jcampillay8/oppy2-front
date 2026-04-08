// lib/features/roleplay_ia/services/roleplay_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/avatar_model.dart';

class RoleplayService {
  final ApiClient _apiClient;
  RoleplayService(this._apiClient);

  Future<List<AvatarModel>> getPublicAvatars() async {
    try {
      final response = await _apiClient.dio.get('/avatars/public');
      return (response.data as List).map((e) => AvatarModel.fromJson(e)).toList();
    } catch (e) { throw _handleError(e); }
  }

  Future<List<AvatarModel>> getMyAvatars() async {
    try {
      final response = await _apiClient.dio.get('/avatars/me');
      return (response.data as List).map((e) => AvatarModel.fromJson(e)).toList();
    } catch (e) { throw _handleError(e); }
  }

  /// NUEVO MÉTODO: Guarda o actualiza el avatar en FastAPI
  Future<AvatarModel> saveAvatar(AvatarModel avatar) async {
    try {
      if (avatar.guid.isEmpty) {
        // CREAR: POST /avatars/
        final response = await _apiClient.dio.post('/avatars/', data: avatar.toJson());
        return AvatarModel.fromJson(response.data);
      } else {
        // ACTUALIZAR: PUT /avatars/{guid}
        final response = await _apiClient.dio.put('/avatars/${avatar.guid}', data: avatar.toJson());
        return AvatarModel.fromJson(response.data);
      }
    } catch (e) { throw _handleError(e); }
  }

  Future<void> deleteAvatar(String guid) async {
    try {
      await _apiClient.dio.delete('/avatars/$guid');
    } catch (e) { throw _handleError(e); }
  }

  Future<Map<String, dynamic>> processChatStep({required String avatarGuid, required String message}) async {
    try {
      final response = await _apiClient.dio.post('/chat/message', data: {
        'avatar_guid': avatarGuid,
        'content': message,
        'type': 'text',
      });
      return response.data;
    } catch (e) { throw _handleError(e); }
  }

  dynamic _handleError(dynamic e) {
    if (e is DioException) return e.response?.data['detail'] ?? "Error de servidor";
    return e.toString();
  }
}

final roleplayServiceProvider = Provider<RoleplayService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RoleplayService(apiClient);
});