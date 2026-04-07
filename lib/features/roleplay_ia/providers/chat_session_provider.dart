// lib/features/roleplay_ia/providers/chat_session_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/avatar_model.dart';
import '../services/roleplay_service.dart';

// Modelo simple para el estado de los mensajes
class ChatMessage {
  final String text;
  final bool isUser;
  final String? feedback; // Para el highlighted_diff
  final String? audioUrl;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.feedback,
    this.audioUrl,
    required this.timestamp,
  });
}

/// StateNotifier que maneja la lógica de la sesión de chat activa
class ChatSessionNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  final RoleplayService _service;
  AvatarModel? _currentAvatar;

  ChatSessionNotifier(this._service) : super(const AsyncValue.data([]));

  /// Inicializa la sesión con el Avatar (Sofía, Aura, etc.)
  void startSession(AvatarModel avatar) {
    _currentAvatar = avatar;
    // Aquí podrías cargar mensajes previos del backend si existen
    if (state.value?.isEmpty ?? true) {
      _addSystemMessage("¡Hi! I'm ${avatar.name}. Let's start our practice: ${avatar.title}");
    }
  }

  /// Envía mensaje de texto al Backend
  Future<void> sendTextMessage(String text) async {
    if (_currentAvatar == null) return;

    final userMsg = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    // Actualizamos la UI inmediatamente con el mensaje del usuario
    state = AsyncValue.data([...state.value ?? [], userMsg]);

    try {
      // Llamada al backend (usando el servicio)
      // El backend debería retornar el texto del bot + feedback gramatical
      final response = await _service.processChatStep(
        avatarGuid: _currentAvatar!.guid,
        message: text,
      );

      final botMsg = ChatMessage(
        text: response['bot_response'],
        isUser: false,
        feedback: response['grammar_feedback'], // "Silent Diagnosis"
        timestamp: DateTime.now(),
      );

      state = AsyncValue.data([...state.value ?? [], botMsg]);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void _addSystemMessage(String text) {
    final msg = ChatMessage(
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
    );
    state = AsyncValue.data([...state.value ?? [], msg]);
  }

  /// Limpiar la sesión al salir
  void clearSession() {
    state = const AsyncValue.data([]);
    _currentAvatar = null;
  }
}

/// Provider global para la sesión de chat
final chatSessionProvider = StateNotifierProvider<ChatSessionNotifier, AsyncValue<List<ChatMessage>>>((ref) {
  final service = ref.watch(roleplayServiceProvider);
  return ChatSessionNotifier(service);
});