// lib/features/roleplay_ia/screens/tutor_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/avatar_provider.dart';
import '../widgets/avatar_card.dart';

import '../../../core/widgets/main_drawer.dart';

class TutorSelectionScreen extends ConsumerWidget {
  const TutorSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarsState = ref.watch(avatarProvider);

    return Scaffold(
      drawer: const MainDrawer(),
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Tus Personajes',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: Colors.white, letterSpacing: 0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white70),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/avatar-editor'),
        backgroundColor: Colors.white,
        icon: const Icon(Icons.add, color: Colors.black87),
        label: const Text("Crear Personaje", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
      body: avatarsState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        error: (err, stack) => _buildErrorState(ref, err),
        data: (allAvatars) {
          return RefreshIndicator(
            onRefresh: () => ref.read(avatarProvider.notifier).loadAvatars(),
            child: allAvatars.isEmpty
              ? _buildEmptyState(context)
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = 2;
                        if (constraints.maxWidth > 1000) {
                          crossAxisCount = 5;
                        } else if (constraints.maxWidth > 800) {
                          crossAxisCount = 4;
                        } else if (constraints.maxWidth > 500) {
                          crossAxisCount = 3;
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 24,
                            crossAxisSpacing: 24,
                            childAspectRatio: 0.75, // Proporción más equilibrada
                          ),
                          itemCount: allAvatars.length,
                          itemBuilder: (context, index) {
                            final avatar = allAvatars[index];
                            return AvatarCard(
                              avatar: avatar,
                              onTap: () => Navigator.pushNamed(context, '/chat-view', arguments: avatar),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_outlined, color: Colors.white.withValues(alpha: 0.2), size: 80),
          const SizedBox(height: 24),
          const Text(
            "Sin personajes aún",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            "Crea tu primer tutor para empezar a conversar\ny mejorar tus habilidades.",
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref, Object err) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.redAccent.withValues(alpha: 0.5), size: 50),
          const SizedBox(height: 16),
          Text('Error: $err', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => ref.read(avatarProvider.notifier).loadAvatars(),
            child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}