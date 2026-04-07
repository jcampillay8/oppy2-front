// lib/features/roleplay_ia/screens/chat_view_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../models/avatar_model.dart';
import '../providers/chat_session_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/feedback_panel.dart';

class ChatViewScreen extends ConsumerStatefulWidget {
  final AvatarModel avatar;

  const ChatViewScreen({super.key, required this.avatar});

  @override
  ConsumerState<ChatViewScreen> createState() => _ChatViewScreenState();
}

class _ChatViewScreenState extends ConsumerState<ChatViewScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Iniciamos la sesión con el avatar seleccionado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatSessionProvider.notifier).startSession(widget.avatar);
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatSessionProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.cardGrey,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.avatar.title, style: const TextStyle(fontSize: 16)),
            Text(widget.avatar.name, 
              style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showScenarioContext(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Área de mensajes
          Expanded(
            child: chatState.when(
              data: (messages) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) => ChatBubble(message: messages[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),

          // Panel de Feedback (Se activa cuando hay correcciones)
          const FeedbackPanel(),

          // Input de texto y micrófono
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Escribe en inglés...",
                  hintStyle: const TextStyle(color: AppColors.textGrey),
                  border: InputBorder.none,
                ),
                onSubmitted: (val) => _sendMessage(),
              ),
            ),
            // Botón de Micrófono (Para el JIT Practice)
            GestureDetector(
              onLongPressStart: (_) => _startRecording(),
              onLongPressEnd: (_) => _stopRecording(),
              child: CircleAvatar(
                backgroundColor: AppColors.accentBlue,
                child: const Icon(Icons.mic, color: Colors.white),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: AppColors.accentBlue),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;
    ref.read(chatSessionProvider.notifier).sendTextMessage(_textController.text);
    _textController.clear();
  }

  void _startRecording() {
    // Lógica para grabar audio
    debugPrint("Grabando...");
  }

  void _stopRecording() {
    // Lógica para enviar audio al backend
    debugPrint("Procesando audio...");
  }

  void _showScenarioContext(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardGrey,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Contexto del Escenario", 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            Text(widget.avatar.context ?? "No hay contexto definido.", 
              style: const TextStyle(color: AppColors.textGrey)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}