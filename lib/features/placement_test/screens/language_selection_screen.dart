// lib/features/placement_test/screens/language_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:oppy2_frontend/core/theme/app_theme.dart';
import 'package:oppy2_frontend/features/auth/services/auth_service.dart';
import 'package:oppy2_frontend/core/network/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final AuthService _authService = AuthService(ApiClient(const FlutterSecureStorage()));
  bool _isLoading = false;

  Future<void> _handleLanguageSelect(String langCode) async {
    setState(() => _isLoading = true);
    
    // Llamada al endpoint /select-language del backend
    final success = await _authService.updateTargetLanguage(langCode);

    setState(() => _isLoading = false);

    if (success && mounted) {
      // Navegamos a la intro del test pasando el código del idioma
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
                  "¿Qué lenguaje desea aprender?",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                _buildOption("English", "🇺🇸", "en"),
                const SizedBox(height: 20),
                _buildOption("Español", "🇪🇸", "es"),
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

  Widget _buildOption(String label, String flag, String code) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: ListTile(
        onTap: () => _handleLanguageSelect(code),
        tileColor: Colors.white.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.outlineGrey),
        ),
        leading: Text(flag, style: const TextStyle(fontSize: 30)),
        title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.textGrey, size: 16),
      ),
    );
  }
}