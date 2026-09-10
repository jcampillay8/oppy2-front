import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/learning_path_model.dart';
import '../services/ielts_path_service.dart';

class IeltsPathState {
  final List<LearningPathUnitProgress> progress;
  final Map<String, dynamic> syllabus;
  final Map<String, dynamic> activityStats;
  final SmartReviewSuggestionModel? smartReviewSuggestion;

  IeltsPathState({
    required this.progress,
    required this.syllabus,
    required this.activityStats,
    this.smartReviewSuggestion,
  });
}

class IeltsPathNotifier extends StateNotifier<AsyncValue<IeltsPathState>> {
  final IeltsPathService _service;

  IeltsPathNotifier(this._service) : super(const AsyncValue.loading()) {
    loadData();
  }

  Future<void> loadData() async {
    state = const AsyncValue.loading();
    try {
      final progress = await _service.getProgress();
      final syllabus = await _service.getSyllabus();
      final activityStats = await _service.getActivityStats();
      SmartReviewSuggestionModel? smartReview;
      try {
        smartReview = await _service.getSmartReviewSuggestion();
      } catch (_) {}

      state = AsyncValue.data(IeltsPathState(
        progress: progress,
        syllabus: syllabus,
        activityStats: activityStats,
        smartReviewSuggestion: smartReview,
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<UnitCompleteResponse?> completeUnit(int level, int unit, double precisionScore) async {
    try {
      final response = await _service.completeUnit(level, unit, precisionScore);
      await loadData();
      return response;
    } catch (e) {
      return null;
    }
  }
}

final ieltsPathProvider = StateNotifierProvider<IeltsPathNotifier, AsyncValue<IeltsPathState>>((ref) {
  final service = ref.watch(ieltsPathServiceProvider);
  return IeltsPathNotifier(service);
});
