// lib/features/placement_test/screens/test_intro_screen.dart
import 'package:flutter/material.dart';
import 'package:oppy2_frontend/core/theme/app_theme.dart';

class TestIntroScreen extends StatelessWidget {
  const TestIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Recibimos el código del idioma ('en' o 'es')
    final String langCode = ModalRoute.of(context)!.settings.arguments as String? ?? 'en';
    final bool isEnglish = langCode == 'en';

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  isEnglish 
                    ? 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Flag_of_the_United_Kingdom_%281-2%29.svg/1200px-Flag_of_the_United_Kingdom_%281-2%29.svg.png'
                    : 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Flag_of_Spain.svg/1200px-Flag_of_Spain.svg.png',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                isEnglish ? "Tu Test de Nivel de Inglés" : "Tu Test de Nivel de Español",
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                "Evaluaremos tus habilidades actuales en 4 áreas clave para que nuestra IA pueda personalizar tu plan de estudio.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGrey, fontSize: 16),
              ),
              const SizedBox(height: 40),
              _buildSkillRow(Icons.edit, "Writing", "Gramática y estructura"),
              _buildSkillRow(Icons.book, "Reading", "Comprensión lectora"),
              _buildSkillRow(Icons.headset, "Listening", "Entendiendo el inglés hablado"),
              _buildSkillRow(Icons.mic, "Speaking", "Pronunciación y fluidez"),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Aquí navegaremos al test real de writing
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("Empezar Test (10 min) →", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillRow(IconData icon, String title, String sub) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.primaryBlue, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text(sub, style: const TextStyle(color: AppColors.textGrey, fontSize: 14)),
            ],
          )
        ],
      ),
    );
  }
}