// lib/features/home/widgets/featured_groups.dart
import 'package:flutter/material.dart';
import 'package:oppy2_frontend/core/theme/app_theme.dart';

class FeaturedGroups extends StatelessWidget {
  const FeaturedGroups({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Grupos Destacados', 
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {}, 
              child: const Text('Explorar', style: TextStyle(color: AppColors.primaryBlue))
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildGroupCard(
          icon: Icons.business_center,
          title: 'English for Business',
          members: '12/20',
          level: 'INTERMEDIO',
        ),
        const SizedBox(height: 12),
        _buildGroupCard(
          icon: Icons.flight_takeoff,
          title: 'Travel & Culture',
          members: '8/15',
          level: 'TODOS',
        ),
      ],
    );
  }

  Widget _buildGroupCard({
    required IconData icon, 
    required String title, 
    required String members, 
    required String level
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardGrey, 
        borderRadius: BorderRadius.circular(16)
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1), 
              borderRadius: BorderRadius.circular(12)
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, 
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.people_outline, color: AppColors.textGrey, size: 14),
                    const SizedBox(width: 4),
                    Text(members, style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
                    const SizedBox(width: 12),
                    Text(level, 
                      style: TextStyle(
                        color: AppColors.primaryBlue.withOpacity(0.8), 
                        fontSize: 12, 
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: AppColors.textGrey, size: 16),
        ],
      ),
    );
  }
}