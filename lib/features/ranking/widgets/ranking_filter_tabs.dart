// lib/features/ranking/widgets/ranking_filter_tabs.dart
import 'package:flutter/material.dart';
import 'package:oppy2_frontend/core/theme/app_theme.dart';

class RankingFilterTabs extends StatelessWidget {
  const RankingFilterTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Un gris azulado muy oscuro
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildTab('Global', isActive: true),
          _buildTab('Regional', isActive: false),
          _buildTab('Amigos', isActive: false),
        ],
      ),
    );
  }

  Widget _buildTab(String label, {required bool isActive}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF334155) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? Colors.blueAccent : AppColors.textGrey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}