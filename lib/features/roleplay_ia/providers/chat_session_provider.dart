// lib/features/roleplay_ia/providers/chat_session_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/avatar_model.dart';
import '../services/roleplay_service.dart';

/// Modelo para los mensajes en la UI
class ChatMessage {
  final String text;
  final bool isUser;
  final dynamic feedback; // Mapa de 'feedback' que devuelve el backend
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.feedback,
    required this.timestamp,
  });
}

class ChatSessionNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  final RoleplayService _service;
  
  String? _activeChatGuid;
  AvatarModel? _currentAvatar;

  // Variable para controlar el estado de "Typing"
  bool _isTyping = false;
  bool get isTyping => _isTyping;

  ChatSessionNotifier(this._service) : super(const AsyncValue.data([]));

  /// Inicializa la sesión: Busca o Crea un chat y RECUPERA el historial
  Future<void> startSession(AvatarModel avatar) async {
    // Si ya estamos en una sesión con este avatar y ya tenemos mensajes, 
    // evitamos recargar todo para que no parpadee la pantalla.
    if (_activeChatGuid != null && _currentAvatar?.guid == avatar.guid && state.hasValue) {
      return;
    }

    state = const AsyncValue.loading();
    _currentAvatar = avatar;

    try {
      // 1. Llamada al backend: getOrCreateChat debe traer el historial de mensajes
      final chatData = await _service.getOrCreateChat(avatar.guid);
      _activeChatGuid = chatData['guid'];

      List<ChatMessage> loadedMessages = [];

      // 2. Mapeamos los mensajes que vienen del backend (si existen)
      if (chatData['messages'] != null && (chatData['messages'] as List).isNotEmpty) {
        final List<dynamic> rawMessages = chatData['messages'];
        
        loadedMessages = rawMessages.map((m) {
          return ChatMessage(
            text: m['content'] ?? '',
            isUser: m['role'] == 'user',
            // Si tu backend guarda el feedback histórico, lo pasamos aquí
            feedback: m['feedback'], 
            timestamp: m['created_at'] != null 
                ? DateTime.parse(m['created_at']) 
                : DateTime.now(),
          );
        }).toList();
      } else {
        // 3. Si el chat es realmente nuevo y no tiene mensajes, ponemos el de bienvenida
        loadedMessages.add(ChatMessage(
          text: "Hi! I'm ${avatar.name}. ${avatar.title}. Let's start!",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      }

      state = AsyncValue.data(loadedMessages);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Envía el mensaje de texto usando el GUID del CHAT
  Future<void> sendTextMessage(String text) async {
    if (_activeChatGuid == null) return;

    final userMsg = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final previousMessages = state.value ?? [];
    
    // Activar estado de escritura y añadir mensaje del usuario inmediatamente
    _isTyping = true;
    state = AsyncValue.data([...previousMessages, userMsg]);

    try {
      final response = await _service.processChatStep(
        chatGuid: _activeChatGuid!,
        message: text,
      );

      final List<dynamic> messagesFromBackend = response['messages'];
      
      // Buscamos la última respuesta del asistente
      final botMessageData = messagesFromBackend.lastWhere(
        (m) => m['role'] == 'assistant',
        orElse: () => {'content': "I'm sorry, I couldn't process that."},
      );

      final botMsg = ChatMessage(
        text: botMessageData['content'],
        isUser: false,
        feedback: response['feedback'], // Score y highlighted_diff
        timestamp: DateTime.now(),
      );

      state = AsyncValue.data([...state.value ?? [], botMsg]);
    } catch (e) {
      print("Error en sendTextMessage: $e");
    } finally {
      _isTyping = false;
      if (state.hasValue) {
        state = AsyncValue.data([...state.value!]);
      }
    }
  }

  void clearSession() {
    _activeChatGuid = null;
    _currentAvatar = null;
    _isTyping = false;
    state = const AsyncValue.data([]);
  }
}

/// Provider global
final chatSessionProvider = StateNotifierProvider<ChatSessionNotifier, AsyncValue<List<ChatMessage>>>((ref) {
  final service = ref.watch(roleplayServiceProvider);
  return ChatSessionNotifier(service);
});