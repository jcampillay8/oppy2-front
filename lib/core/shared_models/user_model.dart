// lib/core/shared_models/user_model.dart
class UserModel {
  final String id;
  final String email;
  final String username;
  final bool hasTested; // <--- Nuevo campo para el flujo de EdTech

  UserModel({
    required this.id, 
    required this.email, 
    required this.username,
    required this.hasTested, // Lo marcamos como requerido
  });

  // Factory para convertir el JSON del backend a un objeto Dart
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      email: json['email'],
      username: json['username'],
      // Mapeamos el campo desde el JSON de FastAPI. 
      // Usamos ?? false como respaldo por si el backend no lo envía.
      hasTested: json['has_tested'] ?? false, 
    );
  }

  // Opcional: Método para convertir el objeto a JSON (útil para guardar en local)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'has_tested': hasTested,
    };
  }
}