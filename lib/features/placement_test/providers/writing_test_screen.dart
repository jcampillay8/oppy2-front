// lib/features/placement_test/screens/writing_test_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/writing_test_provider.dart';
import '../../../core/theme/app_theme.dart';
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
  Timer? _timer;
  int _secondsRemaining = 600; 

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateWordCount);
    _startTimer();
  }

  void _updateWordCount() {
    final text = _controller.text.trim();
    if (mounted) {
      setState(() {
        _wordCount = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
        }
      } else {
        _timer?.cancel();
        _autoSubmit();
      }
    });
  }

  void _autoSubmit() {
    if (_controller.text.isNotEmpty) {
      ref.read(writingTestProvider.notifier).submitAnswer(_controller.text);
    }
  }

  String _formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$mins:$secs";
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final testState = ref.watch(writingTestProvider);

    // ESCUCHADOR DE NAVEGACIÓN
    ref.listen(writingTestProvider, (previous, next) {
      // ✅ Verificación robusta del cambio de estado
      final wasLoading = previous?.isLoading ?? false;
      final isDoneLoading = next.isLoading == false;
      final hasData = next.evaluationResult != null;

      if (wasLoading && isDoneLoading && hasData) {
        _timer?.cancel(); 
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            // ✅ NUNCA uses 'const' aquí si ReadingTestScreen tiene lógica interna
            builder: (context) => ReadingTestScreen(), 
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: _buildAppBar(),
      body: testState.isLoading && testState.question == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : _buildBody(testState),
    );
  }

  Widget _buildBody(WritingTestState state) {
    if (state.error != null && state.question == null) {
      return _buildErrorView(state.error!);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBadge(),
          const SizedBox(height: 16),
          Text(
            "Writing Task",
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: 28, 
              color: Colors.white,
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 12),
          Text(
            state.question?.question ?? "Loading prompt...",
            style: const TextStyle(color: Colors.white70, fontSize: 17, height: 1.4),
          ),
          const SizedBox(height: 24),
          _buildInfoRow(),
          const SizedBox(height: 24),
          _buildEditor(state.isLoading),
          const SizedBox(height: 24),
          _buildAIPrompt(),
          const SizedBox(height: 40),
          _buildNextButton(state.isLoading),
        ],
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
        _infoChip(Icons.access_time, _formatTime(_secondsRemaining)),
        const SizedBox(width: 12),
        _infoChip(Icons.text_fields, "Min. $_minWords words"),
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

  Widget _buildEditor(bool isLoading) {
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
            enabled: !isLoading,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: "Start writing your answer here...",
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
                "$_wordCount / $_minWords words",
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
              "Our AI will analyze your grammar and vocabulary variety in this response.",
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
        onPressed: (_wordCount >= 10 && !isLoading) 
            ? () => ref.read(writingTestProvider.notifier).submitAnswer(_controller.text) 
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          disabledBackgroundColor: AppColors.outlineGrey,
        ),
        child: isLoading 
          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
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

  PreferredSizeWidget _buildAppBar() {
     return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('SECCIÓN 1 DE 4', style: TextStyle(fontSize: 14, letterSpacing: 1.5, color: Colors.white)),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: 0.25,
            backgroundColor: AppColors.outlineGrey,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
          ),
        ),
      );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(error, style: const TextStyle(color: Colors.white)),
          TextButton(
            onPressed: () => ref.read(writingTestProvider.notifier).loadQuestion(),
            child: const Text("Retry"),
          )
        ],
      ),
    );
  }
}