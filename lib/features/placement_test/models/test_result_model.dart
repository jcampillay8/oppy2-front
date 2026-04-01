// lib/features/placement_test/models/test_result_model.dart
class TestResult {
  final String globalLevel;
  final String levelName;
  final Map<String, double> scores;
  final String aiAnalysis;
  final String suggestedPlan;
  final List<NextStep> nextSteps;

  TestResult({
    required this.globalLevel,
    required this.levelName,
    required this.scores,
    required this.aiAnalysis,
    required this.suggestedPlan,
    required this.nextSteps,
  });

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      globalLevel: json['global_level'],
      levelName: json['level_name'],
      scores: Map<String, double>.from(json['scores'].map((k, v) => MapEntry(k, v.toDouble()))),
      aiAnalysis: json['ai_analysis'],
      suggestedPlan: json['suggested_plan'],
      nextSteps: (json['next_steps'] as List).map((i) => NextStep.fromJson(i)).toList(),
    );
  }
}

class NextStep {
  final String icon;
  final String title;
  final String desc;

  NextStep({required this.icon, required this.title, required this.desc});

  factory NextStep.fromJson(Map<String, dynamic> json) {
    return NextStep(icon: json['icon'], title: json['title'], desc: json['desc']);
  }
}