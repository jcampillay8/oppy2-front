// lib/features/roleplay_ia/services/roleplay_service.dart
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart'; // Ajusta según tu ruta real
import '../models/avatar_model.dart';

class RoleplayService {
  final ApiClient _apiClient;

  RoleplayService(this._apiClient);

  /// Obtiene todos los avatares públicos (Escenarios curados por Oppy)
  Future<List<AvatarModel>> getPublicAvatars() async {
    try {
      final response = await _apiClient.dio.get('/avatars/public');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => AvatarModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtiene los avatares creados por el usuario actual
  Future<List<AvatarModel>> getMyAvatars() async {
    try {
      final response = await _apiClient.dio.get('/avatars/me');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => AvatarModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Crea un nuevo avatar personalizado
  Future<AvatarModel> createAvatar(AvatarModel avatar) async {
    try {
      final response = await _apiClient.dio.post(
        '/avatars/',
        data: avatar.toJson(),
      );
      return AvatarModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Actualiza un avatar existente
  Future<AvatarModel> updateAvatar(String guid, AvatarModel avatar) async {
    try {
      final response = await _apiClient.dio.put(
        '/avatars/$guid',
        data: avatar.toJson(),
      );
      return AvatarModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Elimina un avatar (Soft delete usualmente en backend)
  Future<void> deleteAvatar(String guid) async {
    try {
      await _apiClient.dio.delete('/avatars/$guid');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Centralización de errores básica
  String _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionError) {
      return "No se pudo conectar con el servidor (10.0.2.2).";
    }
    return e.response?.data['detail'] ?? "Error inesperado en el servicio de Roleplay";
  }
}