// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:oppy2_frontend/core/theme/app_theme.dart';

class AppColors {
  // Colores Base
  static const Color primaryBlue = Color(0xFF3B82F6); // Azul brillante Oppy
  static const Color accentBlue = primaryBlue;
  static const Color backgroundDark = Color(0xFF0F172A); // Fondo profundo
  static const Color cardGrey = Color(0xFF1E293B);   // Fondo de tarjetas
  
  // Colores de Acento y Estado
  static const Color accentYellow = Color(0xFFFBBF24); // Oro / Energía
  static const Color successGreen = Color(0xFF34D399); // Online / Coach
  static const Color accentPurple = Color(0xFFA78BFA); // Roleplay IA
  
  // Neutros
  static const Color textGrey = Color(0xFF94A3B8);
  static const Color outlineGrey = Color(0xFF334155);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      // Configuramos el esquema global para que los widgets lo tomen por defecto
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryBlue,
        secondary: AppColors.accentYellow,
        surface: AppColors.cardGrey,
        onSurface: Colors.white,
      ),
      // Definimos estilos de texto reutilizables
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textGrey,
        ),
      ),
    );
  }
}