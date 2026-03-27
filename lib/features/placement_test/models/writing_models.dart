// lib/features/placement_test/models/writing_models.dart

class WritingQuestion {
  final String question;
  final String targetLanguage;

  WritingQuestion({
    required this.question, 
    required this.targetLanguage,
  });

  factory WritingQuestion.fromJson(Map<String, dynamic> json) {
    return WritingQuestion(
      question: json['question'] ?? 'No question provided',
      targetLanguage: json['target_language'] ?? 'en',
    );
  }

  WritingQuestion copyWith({
    String? question,
    String? targetLanguage,
  }) {
    return WritingQuestion(
      question: question ?? this.question,
      targetLanguage: targetLanguage ?? this.targetLanguage,
    );
  }
}

// ✅ ESTA ES LA CLASE QUE FALTABA Y CAUSABA LOS ERRORES EN EL PROVIDER
class WritingEvaluation {
  final double score;
  final String feedback;
  final List<String>? suggestions;

  WritingEvaluation({
    required this.score,
    required this.feedback,
    this.suggestions,
  });

  factory WritingEvaluation.fromJson(Map<String, dynamic> json) {
    return WritingEvaluation(
      // Convertimos a double de forma segura (soporta int o double desde el JSON)
      score: (json['score'] ?? 0).toDouble(),
      feedback: json['feedback'] ?? 'No feedback provided',
      suggestions: json['suggestions'] != null 
          ? List<String>.from(json['suggestions']) 
          : null,
    );
  }

  // Útil para debugging o si necesitas clonar el estado
  WritingEvaluation copyWith({
    double? score,
    String? feedback,
    List<String>? suggestions,
  }) {
    return WritingEvaluation(
      score: score ?? this.score,
      feedback: feedback ?? this.feedback,
      suggestions: suggestions ?? this.suggestions,
    );
  }
}