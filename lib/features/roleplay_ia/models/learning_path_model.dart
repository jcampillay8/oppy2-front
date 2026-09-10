class LearningPathUnitProgress {
  final int level;
  final int unit;
  final String status; // "locked", "in_progress", "mastered"
  final double? precisionScore;
  final DateTime? lastPracticedAt;

  LearningPathUnitProgress({
    required this.level,
    required this.unit,
    required this.status,
    this.precisionScore,
    this.lastPracticedAt,
  });

  factory LearningPathUnitProgress.fromJson(Map<String, dynamic> json) {
    return LearningPathUnitProgress(
      level: json['level'],
      unit: json['unit'],
      status: json['status'],
      precisionScore: json['precision_score'] != null ? (json['precision_score'] as num).toDouble() : null,
      lastPracticedAt: json['last_practiced_at'] != null ? DateTime.parse(json['last_practiced_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'unit': unit,
      'status': status,
      'precision_score': precisionScore,
      'last_practiced_at': lastPracticedAt?.toIso8601String(),
    };
  }
}

class UnitCompleteResponse {
  final int level;
  final int unit;
  final String status;
  final double precisionScore;
  final bool unlockedNext;

  UnitCompleteResponse({
    required this.level,
    required this.unit,
    required this.status,
    required this.precisionScore,
    required this.unlockedNext,
  });

  factory UnitCompleteResponse.fromJson(Map<String, dynamic> json) {
    return UnitCompleteResponse(
      level: json['level'],
      unit: json['unit'],
      status: json['status'],
      precisionScore: (json['precision_score'] as num).toDouble(),
      unlockedNext: json['unlocked_next'] ?? false,
    );
  }
}

class SmartReviewSuggestionModel {
  final bool hasMasteredUnits;
  final int? level;
  final int? unit;
  final String? unitTitle;
  final double? precisionScore;
  final int? daysSincePracticed;
  final String? reasonText;

  SmartReviewSuggestionModel({
    required this.hasMasteredUnits,
    this.level,
    this.unit,
    this.unitTitle,
    this.precisionScore,
    this.daysSincePracticed,
    this.reasonText,
  });

  factory SmartReviewSuggestionModel.fromJson(Map<String, dynamic> json) {
    return SmartReviewSuggestionModel(
      hasMasteredUnits: json['has_mastered_units'] ?? false,
      level: json['level'],
      unit: json['unit'],
      unitTitle: json['unit_title'],
      precisionScore: json['precision_score'] != null ? (json['precision_score'] as num).toDouble() : null,
      daysSincePracticed: json['days_since_practiced'],
      reasonText: json['reason_text'],
    );
  }
}
