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

  /// Busca un chat existente para el avatar o crea uno nuevo
  Future<Map<String, dynamic>> getOrCreateChat(String avatarGuid) async {
    try {
      // Llamada al endpoint POST /chats/ que definimos en el backend
      final response = await _apiClient.dio.post('/chats/', data: {
        'avatar_definition_guid': avatarGuid,
      });
      return response.data; // Retorna el objeto Chat con su propio GUID
    } catch (e) { 
      throw _handleError(e); 
    }
  }

  Future<AvatarModel> saveAvatar(AvatarModel avatar) async {
    try {
      if (avatar.guid.isEmpty) {
        final response = await _apiClient.dio.post('/avatars/', data: avatar.toJson());
        return AvatarModel.fromJson(response.data);
      } else {
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

  /// PROCESAR MENSAJE: Ahora usa chatGuid para coincidir con el backend
  Future<Map<String, dynamic>> processChatStep({
    required String chatGuid, 
    required String message
  }) async {
    try {
      // Ajustado a la ruta dinámica: /chats/{chat_guid}/messages/
      final response = await _apiClient.dio.post(
        '/chats/$chatGuid/messages/', 
        data: {
          'content': message,
        },
      );
      return response.data;
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

final roleplayServiceProvider = Provider<RoleplayService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RoleplayService(apiClient);
});