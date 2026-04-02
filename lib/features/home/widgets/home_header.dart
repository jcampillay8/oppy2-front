// lib/features/home/widgets/home_header.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:oppy2_frontend/core/theme/app_theme.dart'; 
import 'package:oppy2_frontend/features/auth/providers/auth_provider.dart';

class HomeHeader extends StatelessWidget {
  final String username;

  const HomeHeader({super.key, required this.username});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardGrey,
        title: const Text('¿Está seguro que desea Cerrar Sesión?', 
          style: TextStyle(color: Colors.white, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('NO', style: TextStyle(color: AppColors.textGrey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pop(context);
              // Aquí podrías redirigir al Login si el provider no lo hace automáticamente
            },
            child: const Text('SI', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PopupMenuButton<String>(
          offset: const Offset(0, 50),
          color: AppColors.cardGrey,
          icon: const CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.cardGrey,
            child: Icon(Icons.person, color: AppColors.textGrey),
          ),
          onSelected: (value) {
            if (value == 'profile') {
              // Navegar a perfil (la crearemos ahora)
              Navigator.pushNamed(context, '/profile');
            } else if (value == 'logout') {
              _showLogoutDialog(context);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'profile',
              child: Text('Ver Perfil', style: TextStyle(color: Colors.white)),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hola de nuevo,', 
              style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
            Text(username, 
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const Spacer(),
        _buildCounterTag(Icons.bolt, '198', AppColors.accentYellow),
        const SizedBox(width: 8),
        _buildCounterTag(Icons.local_fire_department, '12', Colors.orange),
      ],
    );
  }

  Widget _buildCounterTag(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}