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
    Color brandColor = _getColorForString(avatar.name);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2A), // Fondo oscuro elegante
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER: Avatar & Etiqueta ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: brandColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: brandColor.withValues(alpha: 0.3)),
                  ),
                  child: Center(
                    child: Icon(scenarioIcon, color: brandColor, size: 24),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        avatar.isPublic ? Icons.public : Icons.lock_outline,
                        size: 10,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        avatar.isPublic ? 'Público' : 'Privado',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // --- BODY: Textos ---
            Text(
              avatar.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              avatar.title,
              style: TextStyle(
                color: brandColor,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            const Spacer(),
            
            // --- FOOTER: Contexto ---
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                (avatar.context != null && avatar.context!.isNotEmpty)
                    ? avatar.context!
                    : "Sin descripción proporcionada para este personaje.",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
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
    if (t.contains('fantasia') || t.contains('mago') || t.contains('dragón')) return Icons.auto_fix_high;
    if (t.contains('sci-fi') || t.contains('robot') || t.contains('espacio')) return Icons.rocket_launch;
    return Icons.person_outline;
  }

  Color _getColorForString(String text) {
    final colors = [
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEC4899), // Pink
      const Color(0xFF06B6D4), // Cyan
    ];
    int hash = text.hashCode;
    int index = (hash.abs()) % colors.length;
    return colors[index];
  }
}