// lib/features/placement_test/screens/listening_test_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:oppy2_frontend/core/network/api_client.dart';
import 'package:oppy2_frontend/core/theme/app_theme.dart';

class ListeningTestScreen extends ConsumerStatefulWidget {
  const ListeningTestScreen({super.key});

  @override
  ConsumerState<ListeningTestScreen> createState() => _ListeningTestScreenState();
}

class _ListeningTestScreenState extends ConsumerState<ListeningTestScreen> { // <--- Cambiado
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  int _currentQuestionIndex = 0;
  final Map<int, String> _userAnswers = {}; 
  Map<String, dynamic>? _taskData;
  List<dynamic> _questions = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _setupAudioListeners();
    // Usamos Future.microtask para Riverpod
    Future.microtask(() => _fetchListeningTask());
  }

  void _setupAudioListeners() {
    _audioPlayer.onDurationChanged.listen((d) => setState(() => _duration = d));
    _audioPlayer.onPositionChanged.listen((p) => setState(() => _position = p));
    _audioPlayer.onPlayerComplete.listen((_) => setState(() => _isPlaying = false));
  }

  // --- GET: Obtener tarea usando ApiClient ---
  Future<void> _fetchListeningTask() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.dio.get('/onboarding/listening/question');
      
      if (response.statusCode == 200) {
        // Dio ya entrega los datos mapeados
        final data = response.data;
        
        setState(() {
          _taskData = data['task'];
          _questions = _taskData?['questions'] ?? [];
          _isLoading = false;
        });

        await _loadBase64Audio(data['audio_base64']);
      }
    } catch (e) {
      debugPrint("Error loading listening: $e");
    }
  }

  Future<void> _loadBase64Audio(String base64String) async {
    try {
      final bytes = base64Decode(base64String);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/temp_listening.mp3');
      
      await file.writeAsBytes(bytes);
      await _audioPlayer.setSourceDeviceFile(file.path);
    } catch (e) {
      debugPrint("Error processing audio: $e");
    }
  }

  // --- POST: Evaluar usando ApiClient ---
  Future<void> _submitTest() async {
    setState(() => _isSubmitting = true);
    final answersList = List.generate(_questions.length, (index) => _userAnswers[index] ?? "");

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.dio.post(
        '/onboarding/listening/evaluate',
        data: {"answers": answersList},
      );

      if (response.statusCode == 200) {
        debugPrint("Test enviado con éxito: ${response.data}");
        
        if (!mounted) return;
        
        // Feedback y navegación
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Listening completado. ¡Sigue así!")),
        );
        
        // Navegar a la siguiente sección (Speaking)
        Navigator.pushReplacementNamed(context, '/speaking-test');
      }
    } catch (e) {
      debugPrint("Error submitting test: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al enviar respuestas")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

@override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlayback() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  void _handleNext() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() => _currentQuestionIndex++);
    } else {
      _submitTest();
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

    final currentQuestion = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: _buildAppBar(progress),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBadge(),
            const SizedBox(height: 16),
            Text(_taskData?['title'] ?? "", style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const Text("Listen to the audio and answer the question.", style: TextStyle(color: AppColors.textGrey, fontSize: 16)),
            const SizedBox(height: 32),
            _buildAudioCard(),
            const SizedBox(height: 40),
            Text(currentQuestion['question_text'], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ... (currentQuestion['options'] as List).map((opt) => _buildOptionCard(opt['id'], opt['text'])),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  // --- UI Components ---

  PreferredSizeWidget _buildAppBar(double progress) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      title: const Text('SECCIÓN 3 DE 4', style: TextStyle(fontSize: 13, color: Colors.white, letterSpacing: 1.2)),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.outlineGrey,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
        ),
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: const Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.volume_up, color: AppColors.primaryBlue, size: 16),
        SizedBox(width: 8),
        Text("Listening", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildAudioCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineGrey.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12))),
              const SizedBox(width: 16),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Ben", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                Text("Business Meeting Context", style: TextStyle(color: AppColors.textGrey)),
              ])),
              IconButton.filled(
                iconSize: 32,
                onPressed: _togglePlayback,
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                style: IconButton.styleFrom(backgroundColor: AppColors.primaryBlue),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: _position.inSeconds.toDouble().clamp(0.0, _duration.inSeconds.toDouble()),
              max: _duration.inSeconds.toDouble(),
              onChanged: (val) => _audioPlayer.seek(Duration(seconds: val.toInt())),
              activeColor: AppColors.primaryBlue,
              inactiveColor: AppColors.outlineGrey,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(_position), style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                Text(_formatDuration(_duration), style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(String id, String text) {
    bool isSelected = _userAnswers[_currentQuestionIndex] == id;
    return GestureDetector(
      onTap: () => setState(() => _userAnswers[_currentQuestionIndex] = id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primaryBlue : AppColors.outlineGrey, width: isSelected ? 2 : 1),
        ),
        child: Row(children: [
          Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? AppColors.primaryBlue : AppColors.textGrey),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 15))),
        ]),
      ),
    );
  }

  Widget _buildBottomButton() {
    bool hasAnswer = _userAnswers.containsKey(_currentQuestionIndex);
    bool isLast = _currentQuestionIndex == _questions.length - 1;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity, height: 56,
        child: ElevatedButton(
          onPressed: (hasAnswer && !_isSubmitting) ? _handleNext : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue, 
            disabledBackgroundColor: AppColors.outlineGrey.withOpacity(0.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
          ),
          child: _isSubmitting 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(isLast ? "Finalizar Sección →" : "Siguiente →", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    String minutes = d.inMinutes.remainder(60).toString().padLeft(1, '0');
    String seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}