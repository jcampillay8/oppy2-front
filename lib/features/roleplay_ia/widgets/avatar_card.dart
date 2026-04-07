// lib/features/roleplay_ia/widgets/avatar_card.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/avatar_model.dart';

class AvatarCard extends StatelessWidget {
  final AvatarModel avatar;
  final VoidCallback onTap;

  const AvatarCard({
    super.key,
    required this.avatar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    IconData scenarioIcon = _getIconForScenario(avatar.title);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardGrey,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: avatar.isPublic 
                ? AppColors.accentBlue.withOpacity(0.2) 
                : Colors.purple.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // --- 1. INDICADOR DE LIKES (Rating) ---
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite, color: Colors.redAccent, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${avatar.likesCount}', // Nuevo campo
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 11, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- 2. INDICADOR DE TIPO (Público vs Personal) ---
              Positioned(
                top: 12,
                right: 12,
                child: Icon(
                  avatar.isPublic ? Icons.verified : Icons.person_pin,
                  size: 16,
                  color: avatar.isPublic ? AppColors.accentBlue : Colors.purpleAccent,
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // --- 3. ETIQUETA DE CATEGORÍA ---
                    if (avatar.scenarioCategory != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accentBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          avatar.scenarioCategory!.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.accentBlue,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                    // Círculo del Icono
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.backgroundDark,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        scenarioIcon,
                        color: AppColors.accentBlue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Título del Escenario
                    Text(
                      avatar.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Nombre del Personaje
                    Text(
                      "Con ${avatar.name}",
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForScenario(String title) {
    final t = title.toLowerCase();
    if (t.contains('restaurante') || t.contains('comida') || t.contains('café')) return Icons.restaurant;
    if (t.contains('hotel') || t.contains('check') || t.contains('recepción')) return Icons.hotel;
    if (t.contains('aeropuerto') || t.contains('viaje') || t.contains('vuelo')) return Icons.flight_takeoff;
    if (t.contains('trabajo') || t.contains('entrevista') || t.contains('oficina')) return Icons.work;
    if (t.contains('médico') || t.contains('hospital') || t.contains('clínica')) return Icons.local_hospital;
    if (t.contains('tienda') || t.contains('comprar') || t.contains('mall')) return Icons.shopping_bag;
    return Icons.chat_bubble_outline;
  }
}