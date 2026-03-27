// lib/features/placement_test/providers/writing_test_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ✅ USA IMPORTS ABSOLUTOS (Asegúrate que el nombre del package sea 'oppy2_frontend')
import 'package:oppy2_frontend/features/placement_test/models/writing_models.dart';
import 'package:oppy2_frontend/features/placement_test/services/placement_test_service.dart';
import 'package:oppy2_frontend/core/network/api_client.dart';

// 1. Provider del Servicio
final placementTestServiceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider); 
  return PlacementTestService(apiClient);
});

// 2. Estado de la vista
class WritingTestState {
  final bool isLoading;
  final WritingQuestion? question;
  final String? error;
  
  // ✅ Asegúrate que en 'writing_models.dart' la clase se llame exactamente WritingEvaluation
  final WritingEvaluation? evaluationResult;

  WritingTestState({
    this.isLoading = false, 
    this.question, 
    this.error, 
    this.evaluationResult,
  });

  WritingTestState copyWith({
    bool? isLoading, 
    WritingQuestion? question, 
    String? error, 
    WritingEvaluation? evaluationResult, 
  }) {
    return WritingTestState(
      isLoading: isLoading ?? this.isLoading,
      question: question ?? this.question,
      error: error ?? this.error, 
      evaluationResult: evaluationResult ?? this.evaluationResult,
    );
  }
}

// 3. El Notifier
class WritingTestNotifier extends StateNotifier<WritingTestState> {
  final PlacementTestService _service;

  WritingTestNotifier(this._service) : super(WritingTestState()) {
    loadQuestion();
  }

  Future<void> loadQuestion() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final q = await _service.getQuestion();
      state = state.copyWith(isLoading: false, question: q);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> submitAnswer(String answer) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // 1. Obtenemos los datos crudos (Map) del servicio
      final resultData = await _service.evaluateWriting(answer, 'en');
      
      // 2. Mapeamos el Map al modelo WritingEvaluation usando .fromJson
      // ✅ Esto corrige el error de "Map can't be assigned to WritingEvaluation"
      final evaluation = WritingEvaluation.fromJson(resultData);
      
      state = state.copyWith(
        isLoading: false, 
        evaluationResult: evaluation,
      );
    } catch (e) {
      print("Error en submitAnswer: $e");
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// 4. El Provider Global
final writingTestProvider = StateNotifierProvider<WritingTestNotifier, WritingTestState>((ref) {
  final service = ref.watch(placementTestServiceProvider);
  return WritingTestNotifier(service);
});