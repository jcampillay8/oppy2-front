// lib/core/network/api_config.dart
import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    // 🌐 Permite inyectar la URL mediante --dart-define=API_BASE_URL=https://...
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;

    // 🚀 DETECCIÓN AUTOMÁTICA DE AMBIENTE
    if (kReleaseMode) {
      // Producción en Railway / Vercel / App
      return "https://oppy2-back-production.up.railway.app";
    }

    // 🛠️ AMBIENTE DE DESARROLLO (Debug mode)
    if (kIsWeb) return "http://localhost:8000";
    
    if (Platform.isAndroid) {
      // El emulador de Android necesita esta IP para ver el localhost de tu PC
      return "http://10.0.2.2:8000";
    }
    
    return "http://localhost:8000";
  }

  // --- Endpoints ---
  static const String login = "/login/"; 
  static const String register = "/register"; 
  static const String googleMobileSignin = "/auth/google/mobile-signin";

  /// Método para construir la URL completa (mantenemos tu lógica de limpieza)
  static String getFullUrl(String endpoint) {
    final cleanBase = baseUrl.endsWith('/') 
        ? baseUrl.substring(0, baseUrl.length - 1) 
        : baseUrl;
    
    final cleanEndpoint = endpoint.startsWith('/') 
        ? endpoint 
        : '/$endpoint';

    return '$cleanBase$cleanEndpoint';
  }
}