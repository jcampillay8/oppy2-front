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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(
                          isEnglish 
                            ? 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Flag_of_the_United_Kingdom_%281-2%29.svg/1200px-Flag_of_the_United_Kingdom_%281-2%29.svg.png'
                            : 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Flag_of_Spain.svg/1200px-Flag_of_Spain.svg.png',
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        isEnglish ? "Tu Test de Nivel de Inglés" : "Tu Test de Nivel de Español",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 28, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isEnglish 
                          ? "Evaluaremos tus habilidades en 4 áreas clave para personalizar tu plan de estudio."
                          : "Evaluaremos tus habilidades en 4 áreas clave para personalizar tu plan de estudio.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textGrey, fontSize: 16),
                      ),
                      const SizedBox(height: 32),
                      _buildSkillRow(Icons.edit, "Writing", "Gramática y estructura"),
                      _buildSkillRow(Icons.book, "Reading", "Comprensión lectora"),
                      _buildSkillRow(Icons.headset, "Listening", "Entendiendo el idioma hablado"),
                      _buildSkillRow(Icons.mic, "Speaking", "Pronunciación y fluidez"),
                    ],
                  ),
                ),
              ),
              
              // --- EL BOTÓN CORREGIDO ---
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      debugPrint("Iniciando test con idioma: $langCode");
                      
                      // 1. Quitamos los // para activar la línea
                      // 2. Usamos el nombre de ruta correcto: '/writing-test'
                      Navigator.pushNamed(
                        context, 
                        '/writing-test', 
                        arguments: langCode,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white, // Fuerza el color de texto e iconos
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)
                      ),
                    ),
                    child: const Text(
                      "Empezar Test (10 min) →",
                      style: TextStyle(
                        color: Colors.white, // Refuerzo de color blanco
                        fontSize: 18, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
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
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05), 
              borderRadius: BorderRadius.circular(14)
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)
                ),
                const SizedBox(height: 2),
                Text(
                  sub, 
                  style: const TextStyle(color: AppColors.textGrey, fontSize: 14)
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}