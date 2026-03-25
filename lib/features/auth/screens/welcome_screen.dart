// lib/features/auth/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:oppy2_frontend/core/theme/app_theme.dart';
import 'package:oppy2_frontend/features/auth/providers/auth_provider.dart';
import 'package:oppy2_frontend/features/auth/widgets/register_form.dart'; 
import 'package:oppy2_frontend/features/auth/widgets/login_form.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // Función auxiliar para mostrar los formularios
  void _showAuthModal(BuildContext context, Widget form) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Permite ver el diseño del form
      builder: (context) => form,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // 1. Imagen de Fondo
          Positioned(
            top: 0, left: 0, right: 0,
            height: screenHeight * 0.6,
            child: Image.asset(
              'assets/images/bigben.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          // 2. Velo de Degradado
          Positioned(
            top: 0, left: 0, right: 0,
            height: screenHeight * 0.6,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.backgroundDark.withOpacity(0.0),
                    AppColors.backgroundDark.withOpacity(0.2),
                    AppColors.backgroundDark.withOpacity(0.8),
                    AppColors.backgroundDark,
                  ],
                  stops: const [0.0, 0.4, 0.8, 1.0],
                ),
              ),
            ),
          ),

          // 3. Contenido Principal
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const Spacer(),
                  const Icon(Icons.smart_toy_rounded, size: 40, color: AppColors.primaryBlue),
                  const SizedBox(height: 20),
                  const Text('OPPY CHAT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                  Text(
                    'MÁS QUE UN CHAT',
                    style: TextStyle(fontSize: 28, color: Colors.blue.shade400, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'UNA OPORTUNIDAD',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Conversaciones en tiempo real, correcciones instantáneas y lecciones personalizadas.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 40),
                  
                  // BOTÓN EMPEZAR (Muestra el RegisterForm con el SnackBar integrado)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => _showAuthModal(context, const RegisterForm()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('Empezar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // BOTÓN INICIAR SESIÓN
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      onPressed: () => _showAuthModal(context, const LoginForm()),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.outlineGrey),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('Iniciar sesión', style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  const Text('O CONTINÚA CON', style: TextStyle(fontSize: 12, letterSpacing: 2, color: Colors.white54)),
                  const SizedBox(height: 20),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const _SocialIcon(icon: FontAwesomeIcons.apple),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: () => context.read<AuthProvider>().loginWithGoogle(),
                        child: const _SocialIcon(icon: FontAwesomeIcons.google),
                      ),
                      const SizedBox(width: 20),
                      const _SocialIcon(icon: FontAwesomeIcons.envelope),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  const _SocialIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.outlineGrey.withOpacity(0.3),
        border: Border.all(color: AppColors.outlineGrey),
      ),
      child: FaIcon(icon, color: Colors.white, size: 20),
    );
  }
}