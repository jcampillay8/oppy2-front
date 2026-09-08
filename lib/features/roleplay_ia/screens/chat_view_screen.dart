// lib/features/roleplay_ia/screens/chat_view_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../models/avatar_model.dart';
import '../providers/chat_session_provider.dart';
import '../services/roleplay_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/feedback_panel.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class ChatViewScreen extends ConsumerStatefulWidget {
  final AvatarModel avatar;
  const ChatViewScreen({super.key, required this.avatar});

  @override
  ConsumerState<ChatViewScreen> createState() => _ChatViewScreenState();
}

class _ChatViewScreenState extends ConsumerState<ChatViewScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatSessionProvider.notifier).startSession(widget.avatar);
    });
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
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
    final isTyping = ref.watch(chatSessionProvider.notifier).isTyping;

    ref.listen<AsyncValue<List<ChatMessage>>>(chatSessionProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        final messages = next.value!;
        if (messages.length > _lastMessageCount) {
          _lastMessageCount = messages.length;
          final lastMessage = messages.last;
          if (!lastMessage.isUser && widget.avatar.title == 'Simulador Entrevista BHP') {
            _playTTS(lastMessage.text);
          }
        }
      }
    });

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
          if (widget.avatar.title == 'Simulador Entrevista BHP')
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.read(chatSessionProvider.notifier).clearSession();
                ref.read(chatSessionProvider.notifier).startSession(widget.avatar);
              },
            ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showScenarioContext(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chatState.when(
              data: (messages) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length + (isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      return _buildTypingIndicator();
                    }
                    return ChatBubble(message: messages[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // CORREGIDO AQUÍ
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
                    const SizedBox(height: 10),
                    Text('Error: $err', style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
          ),
          const FeedbackPanel(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardGrey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(15),
        ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("${widget.avatar.name} is typing", 
                style: const TextStyle(color: AppColors.textGrey, fontSize: 12, fontStyle: FontStyle.italic)),
              const SizedBox(width: 10),
              const _ThreeDotsAnimation(), // <--- Cambia el CircularProgressIndicator por esto
            ],
          ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(_isRecording ? Icons.stop_circle : Icons.mic, 
                color: _isRecording ? Colors.red : Colors.white),
              onPressed: _toggleRecording,
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Escribe tu respuesta...",
                  hintStyle: TextStyle(color: AppColors.textGrey),
                  border: InputBorder.none,
                ),
                onSubmitted: (val) => _sendMessage(),
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

  Future<void> _playTTS(String text) async {
    try {
      final roleplayService = ref.read(roleplayServiceProvider);
      final audioBytes = await roleplayService.textToSpeech(text);
      await _audioPlayer.play(BytesSource(audioBytes));
    } catch (e) {
      print("TTS Error: \$e");
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _audioRecorder.stop();
      setState(() => _isRecording = false);
      if (path != null) {
        try {
          final roleplayService = ref.read(roleplayServiceProvider);
          final text = await roleplayService.speechToText(path);
          if (text.isNotEmpty) {
            _textController.text = text;
            _sendMessage();
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("STT Error: \$e")));
          }
        }
      }
    } else {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = '\${dir.path}/record.m4a';
        await _audioRecorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
        setState(() => _isRecording = true);
      }
    }
  }

  void _showScenarioContext(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardGrey,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Contexto", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(widget.avatar.context ?? "", style: const TextStyle(color: AppColors.textGrey)),
          ],
        ),
      ),
    );
  }
}

/// Pequeña animación de 3 puntos que parpadean
class _ThreeDotsAnimation extends StatefulWidget {
  const _ThreeDotsAnimation();

  @override
  State<_ThreeDotsAnimation> createState() => _ThreeDotsAnimationState();
}

class _ThreeDotsAnimationState extends State<_ThreeDotsAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            double opacity = ( (_controller.value * 3) - index).clamp(0.2, 1.0);
            return Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}