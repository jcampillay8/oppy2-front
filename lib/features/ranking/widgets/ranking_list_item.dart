// lib/features/ranking/widgets/ranking_list_item.dart
import 'package:flutter/material.dart';
import 'package:oppy2_frontend/core/theme/app_theme.dart';

class RankingListItem extends StatelessWidget {
  final int rank;
  final String name;
  final String country;
  final String points;

  const RankingListItem({
    super.key,
    required this.rank,
    required this.name,
    required this.country,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.cardGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              rank.toString(),
              style: const TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white10,
            child: Icon(Icons.person, color: Colors.white70, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Row(
                  children: [
                    const Icon(Icons.flag, size: 12, color: AppColors.textGrey),
                    const SizedBox(width: 4),
                    Text(country, style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          Text(
            points,
            style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }
}