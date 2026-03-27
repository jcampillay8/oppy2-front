// lib/features/placement_test/screens/writing_test_screen.dart
import 'dart:async'; // Necesario para el Timer
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oppy2_frontend/core/theme/app_theme.dart';
import '../providers/writing_test_provider.dart';
import 'reading_test_screen.dart';

class WritingTestScreen extends ConsumerStatefulWidget {
  const WritingTestScreen({super.key});

  @override
  ConsumerState<WritingTestScreen> createState() => _WritingTestScreenState();
}

class _WritingTestScreenState extends ConsumerState<WritingTestScreen> {
  final TextEditingController _controller = TextEditingController();
  int _wordCount = 0;
  final int _minWords = 250;
  
  // Lógica de Timer
  Timer? _timer;
  int _secondsRemaining = 600; // 10 minutos (ajusta según necesites)

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateWordCount);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        _autoSubmit(); // Enviar automáticamente al llegar a cero
      }
    });
  }

  void _updateWordCount() {
    final text = _controller.text.trim();
    setState(() {
      _wordCount = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    });
  }

  void _autoSubmit() {
    // Si el tiempo se acaba, enviamos lo que el usuario haya escrito
    ref.read(writingTestProvider.notifier).submitAnswer(_controller.text);
  }

  String _formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$mins:$secs";
  }

  @override
  void dispose() {
    _timer?.cancel(); // Limpieza del timer para evitar fugas de memoria
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(writingTestProvider);
  
    ref.listen(writingTestProvider, (previous, next) {
      if (previous?.isLoading == true && next.isLoading == false && next.evaluationResult != null) {
        // Si dejó de cargar y tenemos evaluación -> ¡A Reading!
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ReadingTestScreen()),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close), 
          onPressed: () => Navigator.pop(context)
        ),
        title: const Text('SECCIÓN 1 DE 4', style: TextStyle(fontSize: 14, letterSpacing: 1.5)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: 0.25,
            backgroundColor: AppColors.outlineGrey,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
          ),
        ),
      ),
      body: state.isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
        : state.error != null
          ? _buildErrorView(state.error!)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBadge(),
                  const SizedBox(height: 16),
                  Text("Writing Task", style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 28)),
                  const SizedBox(height: 12),
                  Text(
                    state.question?.question ?? "Cargando pregunta...",
                    style: const TextStyle(color: Colors.white70, fontSize: 17, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoRow(),
                  const SizedBox(height: 24),
                  _buildEditor(),
                  const SizedBox(height: 24),
                  _buildAIPrompt(),
                  const SizedBox(height: 40),
                  _buildNextButton(state.isLoading),
                ],
              ),
            ),
    );
  }

  // --- MÉTODOS DE SOPORTE (UI) ---

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
            TextButton(
              onPressed: () => ref.read(writingTestProvider.notifier).loadQuestion(),
              child: const Text("Reintentar"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.edit_note, color: AppColors.primaryBlue, size: 18),
          SizedBox(width: 8),
          Text("Writing", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInfoRow() {
    return Row(
      children: [
        _infoChip(Icons.access_time, _formatTime(_secondsRemaining)), // Tiempo real
        const SizedBox(width: 12),
        _infoChip(Icons.text_fields, "Min. $_minWords palabras"),
      ],
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.outlineGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineGrey),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textGrey),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildEditor() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineGrey),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: "Empieza a escribir tu respuesta aquí...",
              border: InputBorder.none,
              hintStyle: TextStyle(color: AppColors.textGrey),
            ),
            style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.white),
          ),
          const Divider(color: AppColors.outlineGrey),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.lightbulb_outline, color: AppColors.textGrey, size: 20),
              Text(
                "$_wordCount / $_minWords palabras",
                style: TextStyle(
                  color: _wordCount >= _minWords ? AppColors.primaryBlue : AppColors.textGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAIPrompt() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome, color: AppColors.primaryBlue, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Nuestra IA analizará tu gramática y variedad de vocabulario en esta respuesta.",
              style: TextStyle(color: AppColors.textGrey, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (_wordCount >= 10 && !isLoading) ? () {
          _timer?.cancel(); // Cancelamos el timer si el usuario envía manualmente
          ref.read(writingTestProvider.notifier).submitAnswer(_controller.text);
        } : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          disabledBackgroundColor: AppColors.outlineGrey,
        ),
        child: isLoading 
          ? const SizedBox(
              height: 24, 
              width: 24, 
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Siguiente", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward),
              ],
            ),
      ),
    );
  }
}