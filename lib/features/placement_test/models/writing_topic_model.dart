// lib/features/placement_test/models/writing_topic_model.dart
import 'dart:convert';

class WritingTopic {
  final int id;
  final String title;
  final String prompt;
  final String? category; // Opcional, por si lo agregaste al schema final

  WritingTopic({
    required this.id,
    required this.title,
    required this.prompt,
    this.category,
  });

  /// Factory para crear una instancia desde el JSON que viene de FastAPI
  factory WritingTopic.fromJson(Map<String, dynamic> json) {
    return WritingTopic(
      id: json['id'] as int,
      title: json['title'] as String,
      prompt: json['prompt'] as String,
      category: json['category'] as String?,
    );
  }

  /// Método para convertir el objeto de vuelta a JSON (útil para caché local)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'prompt': prompt,
      'category': category,
    };
  }

  /// Helper para depuración en consola
  @override
  String toString() {
    return 'WritingTopic(id: $id, title: $title)';
  }
}