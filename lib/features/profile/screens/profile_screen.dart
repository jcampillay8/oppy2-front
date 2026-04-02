// lib/features/profile/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:oppy2_frontend/core/theme/app_theme.dart';
import 'package:oppy2_frontend/features/home/widgets/home_bottom_nav.dart';
import 'package:oppy2_frontend/features/auth/providers/auth_provider.dart';
import '../widgets/profile_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ProfileHeader(), // Tu widget existente
                    const SizedBox(height: 24),
                    
                    _buildSectionTitle('Biografía'),
                    _buildBioCard(),
                    
                    // --- Mi aprendizaje ---
                    _buildMenuSection('Mi aprendizaje', [
                      _MenuItem(Icons.flag, 'Nivel objetivo', Colors.blue, trailing: 'Avanzado C1'),
                      _MenuItem(Icons.record_voice_over, 'Voz de IA', Colors.purpleAccent, trailing: 'Británico - H'),
                      _MenuItem(Icons.timer, 'Meta diaria', Colors.tealAccent, trailing: '15 min'),
                    ]),

                    const SizedBox(height: 24),

                    // --- Mis grupos ---
                    _buildMenuSection('Mis grupos', [
                      _MenuItem(Icons.group, 'Inglés para Ingenieros', Colors.indigoAccent, trailing: 'Admin'),
                      _MenuItem(Icons.public, 'Estudiantes en Australia', Colors.greenAccent, trailing: 'Miembro'),
                      _MenuItem(Icons.add_circle_outline, 'Unirse o Crear un grupo', AppColors.textGrey, showArrow: false),
                    ]),

                    const SizedBox(height: 24),

                    // --- Cuenta ---
                    _buildMenuSection('Cuenta', [
                      _MenuItem(Icons.credit_card, 'Suscripción', Colors.orangeAccent, isPro: true),
                      _MenuItem(Icons.email, 'Correo', Colors.blueGrey, trailing: 'alex@example.com'),
                    ]),

                    const SizedBox(height: 24),
                    _buildConfigSection(),

                    const SizedBox(height: 32),
                    _buildLogoutButton(context),
                    const SizedBox(height: 16),
                    const Center(child: Text('Versión 1.0.2', style: TextStyle(color: AppColors.textGrey, fontSize: 12))),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            const HomeBottomNav(initialIndex: 4), // Footer con "Perfil" seleccionado
          ],
        ),
      ),
    );
  }

  // --- WIDGETS INTERNOS PARA MANTENER LIMPIO EL ARCHIVO ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildBioCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.cardGrey, borderRadius: BorderRadius.circular(16)),
      child: const Text(
        'Apasionado por la tecnología y los viajes. Busco mejorar mi inglés técnico para estudiar un magíster en Melbourne.',
        style: TextStyle(color: AppColors.textGrey, fontSize: 14, height: 1.5),
      ),
    );
  }

  Widget _buildMenuSection(String title, List<_MenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        Container(
          decoration: BoxDecoration(color: AppColors.cardGrey, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: items.map((item) => _buildListTile(item)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildListTile(_MenuItem item) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: item.color.withOpacity(0.1), // Fondo sutil del color del ícono
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(item.icon, color: item.color, size: 20),
      ),
      title: Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 15)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.isPro) Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(8)),
            child: const Text('PRO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          if (item.trailing != null) Text(item.trailing!, style: const TextStyle(color: AppColors.textGrey, fontSize: 14)),
          if (item.showArrow) const Icon(Icons.arrow_forward_ios, color: AppColors.textGrey, size: 14),
        ],
      ),
    );
  }

  Widget _buildConfigSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Configuración de la app'),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardGrey,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildSwitchTile(
                title: 'Notificaciones',
                icon: Icons.notifications,
                iconColor: Colors.pinkAccent,
                value: true,
              ),
              _buildSwitchTile(
                title: 'Efectos de sonido',
                icon: Icons.volume_up,
                iconColor: Colors.purpleAccent,
                value: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget auxiliar para los switches con estilo
  Widget _buildSwitchTile({
    required String title,
    required IconData icon,
    required Color iconColor,
    required bool value,
  }) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
      value: value,
      activeColor: AppColors.primaryBlue,
      onChanged: (bool newValue) {
        // Lógica para cambiar estado
      },
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
          '¿Está seguro que desea Cerrar Sesión?',
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
              // 1. Cerramos el diálogo
              Navigator.pop(context);
              // 2. Ejecutamos el logout del provider
              context.read<AuthProvider>().logout();
              // 3. Volvemos a la pantalla de bienvenida/login
              Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
            },
            child: const Text('SI', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// Modelo simple para los items del menú
class _MenuItem {
  final IconData icon;
  final String title;
  final Color color; // Nuevo campo
  final String? trailing;
  final bool isPro;
  final bool showArrow;

  _MenuItem(this.icon, this.title, this.color, {this.trailing, this.isPro = false, this.showArrow = true});
}