// lib/features/roleplay_ia/providers/avatar_provider.dart
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
    // Solo ponemos loading si no hay datos previos para evitar parpadeos molestos
    if (!state.hasValue) {
      state = const AsyncValue.loading();
    }
    
    try {
      final publics = await _service.getPublicAvatars();
      final mine = await _service.getMyAvatars();
      
      // Combinamos ambos en una sola lista para el Lobby. 
      // Los del usuario (mine) primero para que aparezcan arriba.
      state = AsyncValue.data([...mine, ...publics]);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Agregar un nuevo avatar al estado local (útil tras crear uno en el Editor)
  void addAvatar(AvatarModel newAvatar) {
    state.whenData((avatars) {
      state = AsyncValue.data([newAvatar, ...avatars]);
    });
  }

  /// Elimina el avatar tanto en el backend como en el estado local
  Future<void> removeAvatar(String guid) async {
    try {
      await _service.deleteAvatar(guid);
      state.whenData((avatars) {
        state = AsyncValue.data(avatars.where((a) => a.guid != guid).toList());
      });
    } catch (e) {
      // Aquí podrías lanzar una excepción para que la UI muestre un SnackBar
      rethrow;
    }
  }
}

// --- DEFINICIÓN DE LOS PROVIDERS ---

/// El Provider del servicio (ahora usa watch para mayor seguridad)
/// Nota: Si ya lo definiste en el archivo del servicio, puedes borrarlo de aquí
/// para evitar errores de "Duplicate definition".
final roleplayServiceProvider = Provider<RoleplayService>((ref) {
  final apiClient = ref.watch(apiClientProvider); 
  return RoleplayService(apiClient);
});

/// El Provider que usaremos en la UI (Lobby, Editor, etc.)
final avatarProvider = StateNotifierProvider<AvatarNotifier, AsyncValue<List<AvatarModel>>>((ref) {
  final service = ref.watch(roleplayServiceProvider);
  return AvatarNotifier(service);
});