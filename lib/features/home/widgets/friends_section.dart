// lib/features/home/widgets/friends_section.dart
import 'package:flutter/material.dart';
import 'package:oppy2_frontend/core/theme/app_theme.dart';

class FriendsSection extends StatelessWidget {
  const FriendsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Habla con Amigos', 
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                CircleAvatar(radius: 4, backgroundColor: AppColors.successGreen),
                SizedBox(width: 6),
                Text('5 ONLINE', 
                  style: TextStyle(color: AppColors.successGreen, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildAddFriendButton(),
              const SizedBox(width: 16),
              _buildFriendAvatar('Sarah', online: true),
              const SizedBox(width: 16),
              _buildFriendAvatar('Mike', online: true),
              const SizedBox(width: 16),
              _buildFriendAvatar('Elena', online: false),
              const SizedBox(width: 16),
              _buildFriendAvatar('David', online: false),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildAddFriendButton() {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.outlineGrey, width: 2),
          ),
          child: const Icon(Icons.person_add_alt_1, color: AppColors.textGrey),
        ),
        const SizedBox(height: 6),
        const Text('Invitar', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
      ],
    );
  }

  Widget _buildFriendAvatar(String name, {required bool online}) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.cardGrey,
              child: Text(name[0], 
                style: const TextStyle(color: AppColors.textGrey, fontSize: 20)),
            ),
            if (online)
              const Positioned(
                bottom: 0, 
                right: 0,
                child: CircleAvatar(
                  radius: 7, 
                  backgroundColor: AppColors.backgroundDark, 
                  child: CircleAvatar(radius: 5, backgroundColor: AppColors.successGreen)
                ),
              )
          ],
        ),
        const SizedBox(height: 6),
        Text(name, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}