class UserModel {
  final String id;
  final String email;
  final String username;

  UserModel({required this.id, required this.email, required this.username});

  // Factory para convertir el JSON del backend a un objeto Dart
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      email: json['email'],
      username: json['username'],
    );
  }
}