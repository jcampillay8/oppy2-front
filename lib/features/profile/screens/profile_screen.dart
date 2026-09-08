// lib/features/profile/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:oppy2_frontend/core/theme/app_theme.dart';
import 'package:oppy2_frontend/features/auth/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
        ),
        title: const Text('Perfil', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(radius: 50, backgroundColor: AppColors.cardGrey, child: Icon(Icons.person, size: 50, color: Colors.white)),
              const SizedBox(height: 16),
              Text(user?.username ?? 'Estudiante', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(user?.email ?? '', style: const TextStyle(color: AppColors.textGrey, fontSize: 16)),
              const SizedBox(height: 48),
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () => _showLogoutConfirmation(context),
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFF1E293B),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        icon: const Icon(Icons.logout, color: Colors.redAccent),
        label: const Text(
          'Cerrar sesión',
          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '¿Cerrar Sesión?',
          style: TextStyle(color: Colors.white, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('NO', style: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.withOpacity(0.2),
              elevation: 0,
              side: const BorderSide(color: Colors.redAccent),
            ),
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
              Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
            },
            child: const Text('SI', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}