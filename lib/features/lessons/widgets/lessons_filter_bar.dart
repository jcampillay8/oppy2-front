// lib/features/lessons/widgets/lessons_filter_bar.dart
import 'package:flutter/material.dart';
import 'package:oppy2_frontend/core/theme/app_theme.dart';

class LessonsFilterBar extends StatelessWidget {
  const LessonsFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tabs de Nivel
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildLevelTab('Principiante', isActive: true),
            _buildLevelTab('Intermedio', isActive: false),
            _buildLevelTab('Avanzado', isActive: false),
          ],
        ),
        const SizedBox(height: 20),
        // Chips de Categoría
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('Todo', isActive: true),
              _buildFilterChip('Gramática', isActive: false),
              _buildFilterChip('Vocabulario', isActive: false),
              _buildFilterChip('Pronunciación', isActive: false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLevelTab(String label, {required bool isActive}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.primaryBlue : AppColors.textGrey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 15,
          ),
        ),
        if (isActive)
          Container(
            margin: const EdgeInsets.only(top: 8),
            height: 3,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterChip(String label, {required bool isActive}) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryBlue : AppColors.cardGrey,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
    );
  }
}