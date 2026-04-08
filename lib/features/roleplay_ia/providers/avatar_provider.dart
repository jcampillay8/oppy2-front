// lib/features/roleplay_ia/providers/avatar_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/avatar_model.dart';
import '../services/roleplay_service.dart';
import '../../../core/network/api_client.dart'; 

/// StateNotifier para gestionar la lista de avatares (Públicos + Privados)
class AvatarNotifier extends StateNotifier<AsyncValue<List<AvatarModel>>> {
  final RoleplayService _service;

  AvatarNotifier(this._service) : super(const AsyncValue.loading()) {
    loadAvatars();
  }

  /// Carga inicial: Combina avatares públicos y del usuario
  Future<void> loadAvatars() async {
    if (!state.hasValue) {
      state = const AsyncValue.loading();
    }
    
    try {
      final publics = await _service.getPublicAvatars();
      final mine = await _service.getMyAvatars();
      state = AsyncValue.data([...mine, ...publics]);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> upsertAvatar(AvatarModel avatar) async {
    try {
      final savedAvatar = await _service.saveAvatar(avatar);

      state.whenData((currentAvatars) {
        if (avatar.guid.isEmpty) {
          state = AsyncValue.data([savedAvatar, ...currentAvatars]);
        } else {
          // CORRECCIÓN DE TIPO AQUÍ: Usamos .toList() explícito para evitar el error de dynamic
          final updatedList = currentAvatars.map((a) {
            return a.guid == savedAvatar.guid ? savedAvatar : a;
          }).toList();
          
          state = AsyncValue.data(updatedList);
        }
      });
      
      return true;
    } catch (e) {
      print("Error en upsertAvatar: $e");
      return false;
    }
  }

  /// Elimina el avatar tanto en el backend como en el estado local
  Future<void> removeAvatar(String guid) async {
    try {
      await _service.deleteAvatar(guid);
      state.whenData((avatars) {
        state = AsyncValue.data(avatars.where((a) => a.guid != guid).toList());
      });
    } catch (e) {
      rethrow;
    }
  }
}

// --- DEFINICIÓN DE LOS PROVIDERS ---

final roleplayServiceProvider = Provider<RoleplayService>((ref) {
  final apiClient = ref.watch(apiClientProvider); 
  return RoleplayService(apiClient);
});

final avatarProvider = StateNotifierProvider<AvatarNotifier, AsyncValue<List<AvatarModel>>>((ref) {
  final service = ref.watch(roleplayServiceProvider);
  return AvatarNotifier(service);
});