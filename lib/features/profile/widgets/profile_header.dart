// lib/features/profile/widgets/profile_header.dart
import 'package:flutter/material.dart';
import 'package:oppy2_frontend/core/theme/app_theme.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                // Verificamos si hay una pantalla previa en la pila
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  // Si no hay nada (porque usamos pushReplacement), volvemos al Home explícitamente
                  Navigator.pushReplacementNamed(context, '/home');
                }
              },
            ),
            const Spacer(),
            const Text('Perfil y Configuración', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            const SizedBox(width: 48), // Balance visual
          ],
        ),
        const SizedBox(height: 20),
        const Stack(
          children: [
            CircleAvatar(radius: 50, backgroundImage: NetworkImage('https://via.placeholder.com/150')),
            Positioned(
              bottom: 0, right: 0,
              child: CircleAvatar(
                radius: 16, backgroundColor: AppColors.primaryBlue,
                child: Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        const Text('Alex Johnson', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ingeniero Metalúrgico', style: TextStyle(color: AppColors.textGrey, fontSize: 16)),
            SizedBox(width: 4),
            Icon(Icons.edit, color: AppColors.textGrey, size: 14),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified, color: AppColors.primaryBlue, size: 18),
              SizedBox(width: 8),
              Text('Nivel B2 · Intermedio Alto', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text('Miembro desde 2023', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
      ],
    );
  }
}