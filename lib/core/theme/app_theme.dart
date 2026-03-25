// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppColors {
  // El azul brillante del botón "Empezar"
  static const Color primaryBlue = Color(0xFF1E88E5);
  // Fondo oscuro profundo para el modo dark
  static const Color backgroundDark = Color(0xFF0F172A);
  // Color para bordes de botones secundarios
  static const Color outlineGrey = Color(0xFF334155);
  // Texto secundario
  static const Color textGrey = Color(0xFF94A3B8);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryBlue,
        surface: AppColors.backgroundDark,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: AppColors.textGrey,
        ),
      ),
    );
  }
}