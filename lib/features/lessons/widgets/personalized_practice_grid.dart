// lib/features/lessons/widgets/personalized_practice_grid.dart
import 'package:flutter/material.dart';
import 'package:oppy2_frontend/core/theme/app_theme.dart';

class PersonalizedPracticeGrid extends StatelessWidget {
  const PersonalizedPracticeGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildPracticeCard(
          context: context,
          title: 'Roleplay IA',
          subtitle: 'Simula situaciones en restaurantes o viajes.',
          icon: Icons.auto_awesome_motion,
          iconColor: Colors.purpleAccent,
          onTap: () {},
        ),
        const SizedBox(width: 16),
        _buildPracticeCard(
          context: context,
          title: 'Coach de Voz',
          subtitle: 'Mejora tu acento y pronunciación.',
          icon: Icons.mic_none_rounded,
          iconColor: Colors.greenAccent,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildPracticeCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.cardGrey,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.textGrey, fontSize: 11, height: 1.3),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}