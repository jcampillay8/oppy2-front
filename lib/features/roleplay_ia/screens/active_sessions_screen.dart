// lib/features/roleplay_ia/screens/active_sessions_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/avatar_provider.dart';
import '../models/avatar_model.dart';

class ActiveSessionsScreen extends ConsumerWidget {
  const ActiveSessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarsState = ref.watch(avatarProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Mis Conversaciones',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: avatarsState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accentBlue),
        ),
        error: (err, _) => Center(
          child: Text('Error: $err', style: const TextStyle(color: Colors.white)),
        ),
        data: (avatars) {
          // TODO: En el futuro, filtrar por avatares que tengan un 'last_message' real desde el backend
          final activeSessions = avatars.toList();

          if (activeSessions.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(avatarProvider.notifier).loadAvatars(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: activeSessions.length,
              separatorBuilder: (context, index) => const Divider(
                color: AppColors.outlineGrey,
                height: 1,
                indent: 70,
              ),
              itemBuilder: (context, index) {
                return _buildSessionTile(context, activeSessions[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSessionTile(BuildContext context, AvatarModel avatar) {
    return ListTile(
      onTap: () => Navigator.pushNamed(context, '/chat-view', arguments: avatar),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.cardGrey,
            child: Text(
              avatar.name[0].toUpperCase(),
              style: const TextStyle(
                color: AppColors.accentBlue, 
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          // CORRECCIÓN AQUÍ: De 'Position l' a 'Positioned'
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.successGreen,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.backgroundDark, width: 2),
              ),
            ),
          ),
        ],
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              avatar.name,
              style: const TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold, 
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            "12:45 PM", // Placeholder hasta tener timestamp del backend
            style: TextStyle(color: AppColors.textGrey, fontSize: 11),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          avatar.roleAvatar ?? "Practica ahora con este personaje",
          style: TextStyle(
            color: AppColors.textGrey.withOpacity(0.8), 
            fontSize: 13,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios, 
        color: AppColors.outlineGrey, 
        size: 14,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardGrey.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.forum_outlined, 
              size: 64, 
              color: AppColors.accentBlue.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Sin conversaciones activas",
            style: TextStyle(
              color: Colors.white, 
              fontSize: 18, 
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Elige un escenario en el lobby para comenzar a practicar tu inglés.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGrey, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}