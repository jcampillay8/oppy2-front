// lib/features/roleplay_ia/screens/all_scenarios_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/avatar_provider.dart';
import '../widgets/avatar_card.dart';

// Provider local para manejar la búsqueda sin reconstruir todo el árbol innecesariamente
final searchQueryProvider = StateProvider<String>((ref) => "");

class AllScenariosScreen extends ConsumerWidget {
  const AllScenariosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarsState = ref.watch(avatarProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Explorar Escenarios', 
          style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // --- BUSCADOR ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar por título o personaje...',
                hintStyle: TextStyle(color: AppColors.textGrey.withOpacity(0.5)),
                prefixIcon: const Icon(Icons.search, color: AppColors.accentBlue),
                filled: true,
                fillColor: AppColors.cardGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.accentBlue, width: 1),
                ),
              ),
            ),
          ),

          // --- LISTADO ---
          Expanded(
            child: avatarsState.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentBlue)),
              error: (err, _) => Center(child: Text('Error al cargar: $err', style: const TextStyle(color: Colors.white))),
              data: (avatars) {
                // Filtramos la lista basándonos en el buscador
                final filteredAvatars = avatars.where((avatar) {
                  final query = searchQuery.toLowerCase();
                  return avatar.title.toLowerCase().contains(query) || 
                         avatar.name.toLowerCase().contains(query);
                }).toList();

                if (filteredAvatars.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron escenarios', 
                      style: TextStyle(color: AppColors.textGrey)),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: filteredAvatars.length,
                  itemBuilder: (context, index) {
                    final avatar = filteredAvatars[index];
                    return AvatarCard(
                      avatar: avatar,
                      onTap: () => Navigator.pushNamed(
                        context, 
                        '/chat-view', 
                        arguments: avatar
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}