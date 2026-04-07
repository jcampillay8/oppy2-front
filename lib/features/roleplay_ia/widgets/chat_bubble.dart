// lib/features/roleplay_ia/widgets/chat_bubble.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/chat_session_provider.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser ? AppColors.accentBlue : AppColors.cardGrey,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Texto principal del mensaje
            _buildMessageContent(context),
            
            // Si hay feedback (corrección), lo mostramos abajo
            if (message.feedback != null) ...[
              const Divider(color: Colors.white24, height: 20),
              const Text(
                "💡 Suggestion:",
                style: TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 4),
              _parseFeedback(message.feedback!),
            ],
            
            const SizedBox(height: 4),
            Text(
              "${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}",
              style: TextStyle(
                color: isUser ? Colors.white70 : AppColors.textGrey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    return Text(
      message.text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        height: 1.4,
      ),
    );
  }

  /// Lógica para pintar el feedback con colores (Rojo/Verde)
  /// Asume un formato del backend tipo: "I [goed -> went] home"
  Widget _parseFeedback(String feedback) {
    List<TextSpan> spans = [];
    final regex = RegExp(r'\[(.*?) -> (.*?)\]');
    int lastMatchEnd = 0;

    final matches = regex.allMatches(feedback);

    for (var match in matches) {
      // Texto antes del error
      spans.add(TextSpan(
        text: feedback.substring(lastMatchEnd, match.start),
        style: const TextStyle(color: Colors.white70),
      ));

      // El error (Tachado y Rojo)
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(
          color: Colors.redAccent,
          decoration: TextDecoration.lineThrough,
        ),
      ));

      // La corrección (Verde)
      spans.add(const TextSpan(text: " "));
      spans.add(TextSpan(
        text: match.group(2),
        style: const TextStyle(
          color: Colors.greenAccent,
          fontWeight: FontWeight.bold,
        ),
      ));

      lastMatchEnd = match.end;
    }

    // Texto restante
    if (lastMatchEnd < feedback.length) {
      spans.add(TextSpan(
        text: feedback.substring(lastMatchEnd),
        style: const TextStyle(color: Colors.white70),
      ));
    }

    return RichText(
      text: TextSpan(children: spans, style: const TextStyle(fontSize: 13)),
    );
  }
}