// lib/services/auth_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/network/api_config.dart';

class AuthService {
  // Mantenemos tu configuración actual de Dio
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
    followRedirects: false, 
    validateStatus: (status) => status! < 500,
  ));

  final _storage = const FlutterSecureStorage();

  // --- 1. REGISTRO ---
  Future<bool> register(String email, String password, String username) async {
    try {
      final String url = ApiConfig.getFullUrl(ApiConfig.register); 

      final formData = FormData.fromMap({
        "email": email,
        "username": username,
        "password": password,
        "first_name": "Jaime",
        "last_name": "Campillay",
        "terms_accepted": true, 
      });

      final response = await _dio.post(
        url,
        data: formData,
      );

      return response.statusCode != null && response.statusCode! < 300;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  // --- 2. CONFIRMACIÓN DE EMAIL ---
  Future<bool> confirmEmail(String token) async {
    try {
      final String url = "${ApiConfig.baseUrl}/confirm-email/$token";
      
      // Usamos opciones personalizadas para este GET específico
      final response = await _dio.get(
        url,
        options: Options(
          followRedirects: false, // Evitamos que Dio intente seguir a oppychat://
          validateStatus: (status) => status! < 400, // Aceptamos el 307 como éxito
        ),
      );
      
      // Si el status es 200 o 307, la confirmación fue exitosa en el backend
      return response.statusCode == 200 || response.statusCode == 307;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  // --- 3. LOGIN ---
  Future<bool> login(String username, String password) async {
    try {
      final String url = ApiConfig.getFullUrl(ApiConfig.login);
      
      final formData = FormData.fromMap({
        "username": username,
        "password": password,
      });

      final response = await _dio.post(url, data: formData);

      if (response.statusCode == 200) {
        final accessToken = response.data['access_token'];
        final refreshToken = response.data['refresh_token'];
        
        // Guardamos tokens
        await _storage.write(key: 'access_token', value: accessToken);
        await _storage.write(key: 'refresh_token', value: refreshToken);

        // CONFIGURACIÓN CRÍTICA: Añadimos el token a las cabeceras de Dio 
        // para futuras peticiones (como obtener el perfil)
        _dio.options.headers['Authorization'] = 'Bearer $accessToken';
        
        return true;
      }
      return false;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

	// --- 4. GOOGLE SIGN IN ACTUALIZADO ---
  Future<bool> signInWithGoogle(String idToken) async {
    try {
      // ✅ Ahora usamos la constante centralizada
      final String url = ApiConfig.getFullUrl(ApiConfig.googleMobileSignin); 

      print("DEBUG: Intentando POST a $url");

      final response = await _dio.post(
        url,
        data: {
          "id_token": idToken, 
        },
        options: Options(
          contentType: Headers.jsonContentType, 
        ),
      );

      print("DEBUG: Status del Backend: ${response.statusCode}");

      if (response.statusCode == 200) {
        final accessToken = response.data['access_token'];
        final refreshToken = response.data['refresh_token'];
        
        if (accessToken != null) {
          await _storage.write(key: 'access_token', value: accessToken);
          await _storage.write(key: 'refresh_token', value: refreshToken);

          _dio.options.headers['Authorization'] = 'Bearer $accessToken';
          
          print("DEBUG: Login con Google exitoso en OppyChat");
          return true;
        }
      }
      
      print("DEBUG: El backend rechazó el token: ${response.data}");
      return false;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  // --- 5. LOGOUT ---
  Future<void> logout() async {
    await _storage.deleteAll();
    _dio.options.headers.remove('Authorization');
  }

  void _handleError(dynamic e) {
    if (e is DioException) {
      print("--- Error Backend OppyChat ---");
      print("Status: ${e.response?.statusCode}");
      print("Data: ${e.response?.data}");
      print("Message: ${e.message}");
    } else {
      print("Error Inesperado: $e");
    }
  }
}