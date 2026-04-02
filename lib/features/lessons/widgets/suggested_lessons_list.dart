// lib/features/lessons/widgets/suggested_lessons_list.dart
import 'package:flutter/material.dart';
import 'package:oppy2_frontend/core/theme/app_theme.dart';

class SuggestedLessonsList extends StatelessWidget {
  const SuggestedLessonsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildLessonTile(
          title: "El Verbo 'To Be'",
          subtitle: "Gramática • Básico",
          icon: Icons.auto_stories,
          iconColor: Colors.greenAccent,
          trailing: _buildStatusBadge("LOGRO", Colors.orangeAccent),
          isLocked: false,
        ),
        const SizedBox(height: 12),
        _buildLessonTile(
          title: "Sonidos TH",
          subtitle: "Mejora tu acento aprendiendo a posicionar la lengua...",
          icon: Icons.record_voice_over,
          iconColor: Colors.purpleAccent,
          trailing: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: Colors.white10,
            ),
            child: const Text('Comenzar', style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
          isLocked: false,
        ),
        const SizedBox(height: 12),
        _buildLessonTile(
          title: "Presente Perfecto",
          subtitle: "Gramática • Intermedio",
          icon: Icons.school,
          iconColor: Colors.white24,
          trailing: const Icon(Icons.lock_outline, color: Colors.white24, size: 20),
          isLocked: true,
        ),
      ],
    );
  }

  Widget _buildLessonTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Widget trailing,
    bool isLocked = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardGrey.withOpacity(isLocked ? 0.5 : 1.0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isLocked ? Colors.white10 : iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: isLocked ? Colors.white24 : iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isLocked ? Colors.white24 : Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Column(
      children: [
        Icon(Icons.verified, color: color, size: 20),
        const SizedBox(height: 4),
        Text(text, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
      ],
    );
  }
}