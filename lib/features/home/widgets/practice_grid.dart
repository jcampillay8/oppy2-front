// lib/features/home/widgets/practice_grid.dart
import 'package:flutter/material.dart';
import 'package:oppy2_frontend/core/theme/app_theme.dart';

class PracticeGrid extends StatelessWidget {
  const PracticeGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Práctica Personalizada', 
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMainPracticeCard(
                icon: Icons.smart_toy_outlined,
                iconColor: AppColors.accentPurple,
                title: 'Roleplay IA',
                subtitle: 'Simula situaciones en restaurantes.',
                onTap: () => Navigator.pushNamed(context, '/roleplay-lobby'), // 👈 Enrutamiento
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMainPracticeCard(
                icon: Icons.mic_none_outlined,
                iconColor: AppColors.successGreen,
                title: 'Coach de Voz',
                subtitle: 'Mejora tu acento y pronunciación.',
                onTap: () {
                  // Lógica para Coach de Voz en el futuro
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainPracticeCard({
    required IconData icon, 
    required Color iconColor, 
    required String title, 
    required String subtitle,
    required VoidCallback onTap, // 👈 Nuevo parámetro
  }) {
    return GestureDetector( // 👈 Agregamos el detector de gestos
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardGrey, 
          borderRadius: BorderRadius.circular(20)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15), 
                    borderRadius: BorderRadius.circular(14)
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const Icon(Icons.arrow_forward_ios, color: AppColors.textGrey, size: 16),
              ],
            ),
            const SizedBox(height: 24),
            Text(title, 
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(subtitle, 
              style: const TextStyle(color: AppColors.textGrey, fontSize: 13), 
              maxLines: 2, 
              overflow: TextOverflow.ellipsis
            ),
          ],
        ),
      ),
    );
  }
}