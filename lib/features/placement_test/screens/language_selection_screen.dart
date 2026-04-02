// lib/features/placement_test/screens/language_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oppy2_frontend/core/theme/app_theme.dart';
import 'package:oppy2_frontend/features/auth/services/auth_service.dart';

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends ConsumerState<LanguageSelectionScreen> {
  bool _isLoading = false;

  Future<void> _handleLanguageSelect(String langCode) async {
    // Español no disponible aún
    if (langCode == 'es') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.construction_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "¡Próximamente! El curso de Español está en desarrollo.",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(20),
          duration: const Duration(seconds: 3),
        ),
      );
      return; // ← no avanza
    }

    setState(() => _isLoading = true);
    
    final authService = ref.read(authServiceProvider); // ← instancia correcta
    final success = await authService.updateTargetLanguage(langCode);

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pushNamed(context, '/test-diagnostico', arguments: langCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "¿Qué lenguaje deseas aprender?",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                _buildOption("English", "🇺🇸", "en", available: true),
                const SizedBox(height: 20),
                _buildOption("Español", "🇪🇸", "es", available: false),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildOption(String label, String flag, String code, {required bool available}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Opacity(
        opacity: available ? 1.0 : 0.4, // ← visualmente deshabilitado
        child: ListTile(
          onTap: () => _handleLanguageSelect(code),
          tileColor: Colors.white.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.outlineGrey),
          ),
          leading: Text(flag, style: const TextStyle(fontSize: 30)),
          title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          trailing: available
              ? const Icon(Icons.arrow_forward_ios, color: AppColors.textGrey, size: 16)
              : const Icon(Icons.lock_outline, color: AppColors.textGrey, size: 16),
        ),
      ),
    );
  }
}