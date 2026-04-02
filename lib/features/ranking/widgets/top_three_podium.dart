// lib/features/ranking/widgets/top_three_podium.dart
import 'package:flutter/material.dart';
import 'package:oppy2_frontend/core/theme/app_theme.dart';

class TopThreePodium extends StatelessWidget {
  const TopThreePodium({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // PUESTO #2
        _buildPodiumUser(
          name: 'Sarah M.',
          points: '2,300 XP',
          rank: '#2',
          avatarSize: 80,
          color: Colors.blueAccent,
        ),
        const SizedBox(width: 15),
        // PUESTO #1 (Más grande y al centro)
        _buildPodiumUser(
          name: 'John Doe',
          points: '2,540 XP',
          rank: '#1',
          avatarSize: 100,
          color: Colors.amber,
          isWinner: true,
        ),
        const SizedBox(width: 15),
        // PUESTO #3
        _buildPodiumUser(
          name: 'Mike T.',
          points: '2,100 XP',
          rank: '#3',
          avatarSize: 80,
          color: Colors.orangeAccent,
        ),
      ],
    );
  }

  Widget _buildPodiumUser({
    required String name,
    required String points,
    required String rank,
    required double avatarSize,
    required Color color,
    bool isWinner = false,
  }) {
    return Column(
      children: [
        if (isWinner) 
          const Icon(Icons.emoji_events, color: Colors.amber, size: 30), // Icono de corona o similar
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 3),
              ),
              child: CircleAvatar(
                radius: avatarSize / 2,
                backgroundColor: AppColors.cardGrey,
                child: const Icon(Icons.person, color: Colors.white, size: 40),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color, width: 1),
              ),
              child: Text(
                rank,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          points,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}