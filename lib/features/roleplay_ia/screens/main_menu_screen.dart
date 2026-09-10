import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy;
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/main_drawer.dart';
import '../../auth/providers/auth_provider.dart';

class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'OppyChat Tutor',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: Colors.white, letterSpacing: 0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF1E1E2C),
                  title: const Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
                  content: const Text('¿Estás seguro de que deseas salir?', style: TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Salir', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await legacy.Provider.of<AuthProvider>(context, listen: false).logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
                }
              }
            },
          ),
        ],
      ),
      drawer: const MainDrawer(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "¿Qué quieres practicar hoy?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                // 1. Práctica de Vocabulario (SRS)
                _MenuButton(
                  title: "Práctica de Vocabulario",
                  subtitle: "SRS: 15 segundos por palabra",
                  icon: Icons.style,
                  color: Colors.amber,
                  onTap: () => Navigator.pushNamed(context, '/vocabulary-practice'),
                ),
                const SizedBox(height: 20),

                // 2. Guía IELTS (Ruta Primaria Verde)
                _MenuButton(
                  title: "Guía IELTS",
                  subtitle: "Sigue tu ruta de aprendizaje Band 7+",
                  icon: Icons.map_outlined,
                  color: Colors.greenAccent.shade700,
                  isPrimary: true,
                  onTap: () => Navigator.pushNamed(context, '/ielts-path'),
                ),
                const SizedBox(height: 20),
                
                // 3. Listening IELTS (Comprensión Auditiva)
                _MenuButton(
                  title: "Listening IELTS",
                  subtitle: "Entrena tu oído con 8 voces Google TTS",
                  icon: Icons.headphones,
                  color: const Color(0xFF38BDF8),
                  onTap: () => Navigator.pushNamed(context, '/ielts-listening-path'),
                ),
                const SizedBox(height: 20),

                // 4. Chat Libre
                _MenuButton(
                  title: "Chat Libre",
                  subtitle: "Conversa con tus avatares e IA",
                  icon: Icons.chat_bubble_outline,
                  color: Colors.blueAccent,
                  onTap: () => Navigator.pushNamed(context, '/tutor-selection'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isPrimary;

  const _MenuButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isPrimary ? color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
            border: Border.all(
              color: isPrimary ? color.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1),
              width: isPrimary ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
