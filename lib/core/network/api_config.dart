// lib/core/network/api_config.dart
import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) return "http://localhost:8000";
    
    // El emulador de Android necesita esta IP para ver tu localhost
    if (Platform.isAndroid) {
      return "http://10.0.2.2:8000";
    }
    
    return "http://localhost:8000";
  }

  // --- Ajuste de Endpoints ---
  // Quitamos "/auth" y agregamos el "/" al final para que coincida con tu prueba exitosa
  static const String login = "/login/"; 
  static const String register = "/register"; 
  static const String googleMobileSignin = "/auth/google/mobile-signin";

  /// Método para construir la URL completa
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