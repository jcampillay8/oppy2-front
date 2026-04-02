// lib/features/statistics/widgets/recent_topics.dart
import 'package:flutter/material.dart';
import 'package:oppy2_frontend/core/theme/app_theme.dart';

class RecentTopics extends StatelessWidget {
  const RecentTopics({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Temas Recientes',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildTopicTile(
          icon: Icons.flight_takeoff,
          title: 'Viajes y Aeropuertos',
          subtitle: 'Vocabulario B1 • Completado ayer',
          progress: 1.0,
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildTopicTile(
          icon: Icons.business_center,
          title: 'Negocios: Emails',
          subtitle: 'Escritura A2 • En progreso',
          progress: 0.6,
          color: Colors.indigoAccent,
        ),
      ],
    );
  }

  Widget _buildTopicTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required double progress,
    required Color color,
  }) {
    bool isCompleted = progress == 1.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
              ],
            ),
          ),
          if (isCompleted)
            const Icon(Icons.check_circle, color: Colors.greenAccent, size: 24)
          else
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 3,
                    backgroundColor: Colors.white10,
                    color: color,
                  ),
                ),
                Text('${(progress * 100).toInt()}%', 
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
        ],
      ),
    );
  }
}