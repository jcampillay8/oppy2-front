// lib/features/roleplay_ia/screens/avatar_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/avatar_provider.dart';
import 'avatar_editor_screen.dart'; // Importas el editor para saltar a él

class AvatarManagementScreen extends ConsumerWidget {
  const AvatarManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarsState = ref.watch(avatarProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Mis Personajes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AvatarEditorScreen()),
            ),
          ),
        ],
      ),
      body: avatarsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (avatars) {
          // Filtramos para mostrar solo lo que el usuario ha creado (no públicos de otros)
          final myAvatars = avatars.toList(); 

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: myAvatars.length,
            itemBuilder: (context, index) {
              final avatar = myAvatars[index];
              return Card(
                color: AppColors.cardGrey,
                child: ListTile(
                  title: Text(avatar.name, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(avatar.title, style: const TextStyle(color: AppColors.textGrey)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.accentBlue),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AvatarEditorScreen(avatar: avatar)),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          // Lógica para borrar (puedes usar el guid)
                          // ref.read(avatarProvider.notifier).deleteAvatar(avatar.guid);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}