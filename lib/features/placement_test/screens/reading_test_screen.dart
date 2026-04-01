// lib/features/placement_test/screens/reading_test_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:oppy2_frontend/core/theme/app_theme.dart';
import 'package:oppy2_frontend/core/network/api_client.dart';

// --- MODELOS ---
class ReadingOption {
  final String id;
  final String text;
  ReadingOption({required this.id, required this.text});
}

class ReadingQuestion {
  final int id;
  final String questionText;
  final List<ReadingOption> options;
  ReadingQuestion({required this.id, required this.questionText, required this.options});
}

class ReadingTask {
  final String title;
  final String story;
  final String estimatedTime;
  final List<ReadingQuestion> questions;

  ReadingTask({
    required this.title, 
    required this.story, 
    required this.estimatedTime, 
    required this.questions
  });

  factory ReadingTask.fromJson(Map<String, dynamic> json) {
    var questionsJson = json['questions'] as List;
    return ReadingTask(
      title: json['title'],
      story: json['story'],
      estimatedTime: json['estimated_time'],
      questions: questionsJson.map((q) => ReadingQuestion(
        id: q['id'],
        questionText: q['question_text'],
        options: (q['options'] as List).map((o) => ReadingOption(
          id: o['id'],
          text: o['text'],
        )).toList(),
      )).toList(),
    );
  }
}

// --- SCREEN ---
class ReadingTestScreen extends ConsumerStatefulWidget { // <--- Cambiar a ConsumerStatefulWidget
  const ReadingTestScreen({super.key});

  @override
  ConsumerState<ReadingTestScreen> createState() => _ReadingTestScreenState();
}

class _ReadingTestScreenState extends ConsumerState<ReadingTestScreen> { // <--- Cambiar a ConsumerState
  ReadingTask? _task;
  int _currentQuestionIndex = 0;
  final Map<int, String> _userAnswers = {};
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Usamos Future.microtask para llamar al provider después del primer frame
    Future.microtask(() => _fetchReadingTask());
  }

  // --- GET: Obtener la pregunta usando tu ApiClient ---
  Future<void> _fetchReadingTask() async {
    try {
      final apiClient = ref.read(apiClientProvider); // <--- Leemos tu cliente configurado
      final response = await apiClient.dio.get('/onboarding/reading/question');
      
      if (response.statusCode == 200) {
        setState(() {
          _task = ReadingTask.fromJson(response.data); // Dio ya parsea el JSON automáticamente
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching reading: $e");
      // Opcional: mostrar un diálogo de error si falla la conexión
    }
  }

  // --- POST: Evaluar respuestas usando tu ApiClient ---
// --- POST: Evaluar respuestas usando tu ApiClient ---
  Future<void> _submitReadingTest() async {
    setState(() => _isSubmitting = true);
    
    final answersList = _task!.questions.asMap().entries.map((entry) {
      return _userAnswers[entry.key] ?? "";
    }).toList();

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.dio.post(
        '/onboarding/reading/evaluate',
        data: {"answers": answersList},
      );

      if (response.statusCode == 200) {
        debugPrint("Evaluación exitosa: ${response.data}");
        
        if (!mounted) return;

        // 1. Feedback visual para el usuario
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ Reading completado. Nivel: ${response.data['assigned_level']}"),
            backgroundColor: Colors.green.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // 2. NAVEGACIÓN A LA SIGUIENTE SECCIÓN (Listening)
        // Asegúrate de tener '/listening-test' definido en tu main.dart
        Navigator.pushReplacementNamed(context, '/listening-test');
      }
    } catch (e) {
      debugPrint("Error submitting evaluation: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error de conexión al evaluar. Intenta de nuevo.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _handleNext() {
    if (_currentQuestionIndex < _task!.questions.length - 1) {
      setState(() => _currentQuestionIndex++);
    } else {
      _submitReadingTest();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
      );
    }

    final currentQuestion = _task!.questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _task!.questions.length;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        title: const Text('SECCIÓN 2 DE 4', style: TextStyle(fontSize: 13, color: Colors.white, letterSpacing: 1.2)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.outlineGrey,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionBadge(),
            const SizedBox(height: 16),
            Text(_task!.title, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _infoChip(Icons.access_time, _task!.estimatedTime),
                const SizedBox(width: 10),
                _infoChip(Icons.help_outline, "${_task!.questions.length} Preguntas"),
              ],
            ),
            const SizedBox(height: 24),
            _buildStoryBox(_task!.story),
            const SizedBox(height: 32),
            Text(
              "${_currentQuestionIndex + 1}. ${currentQuestion.questionText}",
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...currentQuestion.options.map((option) => _buildOptionCard(option)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  // --- COMPONENTES UI ---

  Widget _buildSectionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book, color: AppColors.primaryBlue, size: 16),
          SizedBox(width: 8),
          Text("Reading", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStoryBox(String text) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineGrey.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.6),
      ),
    );
  }

  Widget _buildOptionCard(ReadingOption option) {
    bool isSelected = _userAnswers[_currentQuestionIndex] == option.id;

    return GestureDetector(
      onTap: () => setState(() => _userAnswers[_currentQuestionIndex] = option.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.outlineGrey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.primaryBlue : AppColors.textGrey,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(option.text, style: const TextStyle(color: Colors.white, fontSize: 15))),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    bool hasSelection = _userAnswers.containsKey(_currentQuestionIndex);
    bool isLastQuestion = _currentQuestionIndex == (_task?.questions.length ?? 0) - 1;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: (hasSelection && !_isSubmitting) ? _handleNext : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            disabledBackgroundColor: AppColors.outlineGrey.withOpacity(0.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: _isSubmitting 
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                isLastQuestion ? "Finalizar Test →" : "Siguiente →", 
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
              ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textGrey),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
        ],
      ),
    );
  }
}