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
            
            // Lógica de Feedback/Sugerencia
            if (message.feedback != null) ...[
              const Divider(color: Colors.white24, height: 20),
              const Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.amberAccent, size: 14),
                  SizedBox(width: 4),
                  Text(
                    "Suggestion:",
                    style: TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _parseFeedback(message.feedback),
            ],
            
            const SizedBox(height: 6),
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

  /// Procesa el feedback adaptándose al formato que envíe el backend
  Widget _parseFeedback(dynamic feedback) {
    // CASO 1: El feedback viene como un Map con la nueva estructura de diffs
    if (feedback is Map<String, dynamic> && feedback.containsKey('highlighted_diff')) {
      final List<dynamic> diffs = feedback['highlighted_diff'];
      List<TextSpan> spans = [];

      for (var part in diffs) {
        final String text = part['text'] ?? "";
        final String type = part['type'] ?? "default";

        if (type == 'removed') {
          // Palabra errónea: Roja y tachada
          spans.add(TextSpan(
            text: "$text ",
            style: const TextStyle(
              color: Colors.redAccent,
              decoration: TextDecoration.lineThrough,
              fontStyle: FontStyle.italic,
            ),
          ));
        } else if (type == 'added') {
          // Sugerencia: Verde y negrita
          spans.add(TextSpan(
            text: "$text ",
            style: const TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
            ),
          ));
        } else {
          // Texto que estaba bien (default)
          spans.add(TextSpan(
            text: "$text ",
            style: const TextStyle(color: Colors.white70),
          ));
        }
      }

      return RichText(
        text: TextSpan(
          children: spans, 
          style: const TextStyle(fontSize: 13, height: 1.5)
        ),
      );
    }

    // CASO 2: El feedback es un String plano (Legacy o fallback)
    if (feedback is String) {
      // Intentamos ver si tiene el formato antiguo [error -> correction]
      if (feedback.contains('->')) {
        return _parseLegacyStringFeedback(feedback);
      }
      return Text(
        feedback,
        style: const TextStyle(color: Colors.white70, fontSize: 13),
      );
    }

    return const SizedBox.shrink();
  }

  /// Mantiene compatibilidad con el formato "[bad -> good]" por si acaso
  Widget _parseLegacyStringFeedback(String feedback) {
    List<TextSpan> spans = [];
    final regex = RegExp(r'\[(.*?) -> (.*?)\]');
    int lastMatchEnd = 0;
    final matches = regex.allMatches(feedback);

    for (var match in matches) {
      spans.add(TextSpan(
        text: feedback.substring(lastMatchEnd, match.start),
        style: const TextStyle(color: Colors.white70),
      ));
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(
          color: Colors.redAccent,
          decoration: TextDecoration.lineThrough,
        ),
      ));
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