// lib/features/placement_test/providers/placement_test_provider.dart
import 'package:flutter/material.dart';
import '../services/placement_test_service.dart';
import '../models/writing_topic_model.dart'; // Crearemos este modelo simple

enum TestStep { languageSelection, dashboard, writing, reading, listening, speaking, completed }

class PlacementTestProvider extends ChangeNotifier {
  final PlacementTestService _service = PlacementTestService();

  // --- ESTADO ---
  TestStep _currentStep = TestStep.languageSelection;
  String? _targetLanguage;
  bool _isLoading = false;
  
  // Datos del Test de Writing
  WritingTopic? _currentWritingTopic;
  double? _writingScore;

  // --- GETTERS ---
  TestStep get currentStep => _currentStep;
  String? get targetLanguage => _targetLanguage;
  bool get isLoading => _isLoading;
  WritingTopic? get currentWritingTopic => _currentWritingTopic;
  double? get writingScore => _writingScore;

  // --- ACCIONES ---

  /// 1. Seleccionar Idioma ('en' o 'es')
  void setLanguage(String lang) {
    _targetLanguage = lang;
    _currentStep = TestStep.dashboard;
    notifyListeners();
  }

  /// 2. Cargar el tema de Writing desde el Backend
  Future<void> startWritingTest(String category) async {
    if (_targetLanguage == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      // Llamamos al endpoint /onboarding/writing/setup
      _currentWritingTopic = await _service.getWritingTopic(
        category: category, 
        language: _targetLanguage!
      );
      _currentStep = TestStep.writing;
    } catch (e) {
      debugPrint("Error al obtener tema: $e");
      // Aquí podrías manejar un error visual
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 3. Enviar respuesta de Writing para evaluación
  Future<bool> submitWriting(String text) async {
    if (_targetLanguage == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Llamamos al endpoint /onboarding/writing/evaluate
      final score = await _service.evaluateWriting(
        text: text, 
        language: _targetLanguage!
      );
      _writingScore = score;
      
      // Volvemos al dashboard para que el usuario vea el check de "completado"
      _currentStep = TestStep.dashboard; 
      return true;
    } catch (e) {
      debugPrint("Error evaluando writing: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Resetear para volver a empezar si es necesario
  void reset() {
    _currentStep = TestStep.languageSelection;
    _targetLanguage = null;
    _currentWritingTopic = null;
    notifyListeners();
  }
}