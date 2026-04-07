// lib/features/roleplay_ia/screens/roleplay_lobby_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/avatar_provider.dart';
import '../widgets/avatar_card.dart';
import '../models/avatar_model.dart';

class RoleplayLobbyScreen extends ConsumerWidget {
  const RoleplayLobbyScreen({super.key});

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
          'Roleplay IA',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: avatarsState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accentBlue),
        ),
        error: (err, stack) => _buildErrorState(ref, err),
        data: (allAvatars) {
          // Tomamos 3 o 4 escenarios al azar o los primeros para la vista previa
          final previewAvatars = allAvatars.take(4).toList();

          return RefreshIndicator(
            onRefresh: () => ref.read(avatarProvider.notifier).loadAvatars(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // 1. SECCIÓN: CONTINUAR PRACTICANDO
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                    child: _buildSectionHeader(
                      "Continuar Practicando",
                      Icons.history,
                      () => Navigator.pushNamed(context, '/active-sessions'),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _buildResumeSection(context),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),

                // 2. SECCIÓN: GESTIÓN DE AVATARS
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                    child: _buildSectionHeader(
                      "Gestión Avatars", 
                      Icons.psychology_outlined, 
                      null
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _buildManagementCard(context),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),

                // 3. SECCIÓN: ELEGIR ESCENARIOS (CON "VER TODOS")
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                    child: _buildSectionHeader(
                      "Elegir Escenarios", 
                      Icons.explore_outlined, 
                      () => Navigator.pushNamed(context, '/all-scenarios'), // Nueva ruta para ver todo
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0, bottom: 16, right: 20.0),
                    child: Text(
                      "Practica en situaciones reales con nuestros escenarios destacados",
                      style: TextStyle(color: AppColors.textGrey.withOpacity(0.8), fontSize: 13),
                    ),
                  ),
                ),

                // Vista Previa de Escenarios (Horizontal o Grid pequeño)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  sliver: previewAvatars.isEmpty
                      ? const SliverToBoxAdapter(child: Text("No hay escenarios disponibles", style: TextStyle(color: AppColors.textGrey)))
                      : SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final avatar = previewAvatars[index];
                              return AvatarCard(
                                avatar: avatar,
                                onTap: () => Navigator.pushNamed(context, '/chat-view', arguments: avatar),
                              );
                            },
                            childCount: previewAvatars.length,
                          ),
                        ),
                ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- COMPONENTES DE APOYO ---

  Widget _buildSectionHeader(String title, IconData icon, VoidCallback? onActionPressed) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accentYellow, size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const Spacer(),
        if (onActionPressed != null)
          TextButton(
            onPressed: onActionPressed,
            child: const Text('Ver todos', style: TextStyle(color: AppColors.accentBlue, fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }

  Widget _buildManagementCard(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/avatar-manager'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.accentBlue.withOpacity(0.15), AppColors.cardGrey],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accentBlue.withOpacity(0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.auto_fix_high_rounded, color: AppColors.accentBlue, size: 30),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Crea, Edita y Elimina', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Tus Propios Avatars Personalizados', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.accentBlue, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildResumeSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineGrey),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.accentPurple.withOpacity(0.2),
            child: const Icon(Icons.psychology, color: AppColors.accentPurple),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Última conversación', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                Text('Camarero IA - Restaurante', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
          ),
          const Icon(Icons.play_arrow_rounded, color: AppColors.successGreen),
        ],
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref, Object err) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, color: Colors.redAccent, size: 50),
          const SizedBox(height: 16),
          Text('Error al conectar: $err', style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => ref.read(avatarProvider.notifier).loadAvatars(),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}