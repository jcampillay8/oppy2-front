// lib/features/placement_test/models/reading_task_model.dart
class ReadingTask {
  final String title;
  final String story;
  final String estimatedTime;
  final List<Question> questions;

  ReadingTask({required this.title, required this.story, required this.estimatedTime, required this.questions});

  factory ReadingTask.fromJson(Map<String, dynamic> json) {
    return ReadingTask(
      title: json['title'],
      story: json['story'],
      estimatedTime: json['estimated_time'],
      questions: (json['questions'] as List).map((q) => Question.fromJson(q)).toList(),
    );
  }
}

class Question {
  final int id;
  final String questionText;
  final List<Option> options;

  Question({required this.id, required this.questionText, required this.options});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      questionText: json['question_text'],
      options: (json['options'] as List).map((o) => Option.fromJson(o)).toList(),
    );
  }
}

class Option {
  final String id;
  final String text;
  Option({required this.id, required this.text});

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(id: json['id'], text: json['text']);
  }
}