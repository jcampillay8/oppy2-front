// lib/features/placement_test/screens/reading_test_screen.dart
import 'package:flutter/material.dart';
import 'package:oppy2_frontend/core/theme/app_theme.dart';

class ReadingTestScreen extends StatelessWidget {
  const ReadingTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () {}),
        title: const Text('SECCIÓN 2 DE 4', style: TextStyle(fontSize: 13, letterSpacing: 1.2)),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {})],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: 0.5, // 50% progreso
            backgroundColor: AppColors.outlineGrey,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge Reading
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.menu_book, color: AppColors.primaryBlue, size: 16),
                  SizedBox(width: 8),
                  Text("Reading", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "The Rise of Urban Gardening",
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _infoChip(Icons.access_time, "~8 min"),
                const SizedBox(width: 10),
                _infoChip(Icons.help_outline, "3 Preguntas"),
              ],
            ),
            const SizedBox(height: 24),
            
            // Cuadro de texto de lectura
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineGrey.withOpacity(0.5)),
              ),
              child: const Text(
                "Urban gardening has gained immense popularity in recent years as city dwellers look for ways to reconnect with nature. By transforming rooftops, balconies, and small patches of land into green spaces, communities can grow their own fresh produce...\n\nThis practice not only provides healthy food but also helps reduce the urban heat island effect.",
                style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.6),
              ),
            ),
            
            const SizedBox(height: 32),
            const Text(
              "1. According to the text, why has urban gardening become popular?",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Opciones (Cards)
            _buildOption("People want to save money on groceries.", false),
            _buildOption("City dwellers want to reconnect with nature.", true), // Seleccionada
            _buildOption("It is a mandatory government program.", false),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildOption(String text, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? Colors.transparent : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primaryBlue : AppColors.outlineGrey,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: isSelected ? AppColors.primaryBlue : AppColors.textGrey,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 15))),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text("Siguiente →", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textGrey),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
        ],
      ),
    );
  }
}