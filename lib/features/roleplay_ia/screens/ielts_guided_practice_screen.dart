import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:confetti/confetti.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';
import '../providers/ielts_path_provider.dart';
import '../services/ielts_path_service.dart';

class IeltsGuidedPracticeScreen extends ConsumerStatefulWidget {
  final int level;
  final int unit;
  final String unitTitle;

  const IeltsGuidedPracticeScreen({
    super.key,
    required this.level,
    required this.unit,
    required this.unitTitle,
  });

  @override
  ConsumerState<IeltsGuidedPracticeScreen> createState() => _IeltsGuidedPracticeScreenState();
}

class _IeltsGuidedPracticeScreenState extends ConsumerState<IeltsGuidedPracticeScreen> {
  final int _totalExercises = 10;
  int _currentExerciseIndex = 0;
  int _correctAnswers = 0;
  int _wildcardsRemaining = 3;
  bool _usedWildcardForCurrentExercise = false;
  List<bool?> _exerciseResults = List.filled(10, null);

  bool _isLoading = true;
  bool _isEvaluating = false;
  Map<String, dynamic>? _challengeData;
  Map<String, dynamic>? _evaluationData;
  
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _deeplSpanishController = TextEditingController();
  String _deeplEnglishResult = "";
  String _deeplTargetLang = "EN-US";
  bool _isTranslatingDeepL = false;
  bool _isSavingDeepLVocab = false;
  bool _deeplSavedInVocab = false;

  final FocusNode _inputFocusNode = FocusNode();
  final FocusNode _nextButtonFocusNode = FocusNode();
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _loadChallenge();
  }

  @override
  void dispose() {
    _textController.dispose();
    _deeplSpanishController.dispose();
    _inputFocusNode.dispose();
    _nextButtonFocusNode.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadChallenge() async {
    if (_currentExerciseIndex >= _totalExercises) {
      _finishSession();
      return;
    }

    setState(() {
      _isLoading = true;
      _evaluationData = null;
      _usedWildcardForCurrentExercise = false;
      _textController.clear();
      _deeplSpanishController.clear();
      _deeplEnglishResult = "";
    });

    try {
      final service = ref.read(ieltsPathServiceProvider);
      final data = await service.generateChallenge(widget.level, widget.unit);
      
      if (mounted) {
        setState(() {
          _challengeData = data;
          _isLoading = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _inputFocusNode.requestFocus();
        });
      }
    } catch (e) {
      debugPrint("Error loading IELTS challenge: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar ejercicio: $e')),
        );
      }
    }
  }

  Future<void> _evaluateTranslation() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _challengeData == null) return;

    setState(() => _isEvaluating = true);

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.dio.post(
        '/learning-analysis/ielts-path/evaluate',
        data: {
          "user_translation": text,
          "grammar_target": _challengeData!['grammar_target'],
          "spanish_sentence": _challengeData!['spanish_sentence']
        }
      );
      
      final errorsFound = (response.data['errors_found'] as List? ?? []);
      final diffs = (response.data['differences'] as List? ?? []);
      final bool isPerfectDiff = diffs.every((d) => d['type'] == 'default');
      
      final bool hasOnlyStylisticSuggestions = errorsFound.isNotEmpty &&
          errorsFound.every((e) => e['category'] == 'StylisticSuggestion');
      final bool hasNoErrors = errorsFound.isEmpty;

      final bool isCorrect = isPerfectDiff || hasNoErrors || hasOnlyStylisticSuggestions;
      
      if (isCorrect) {
        _correctAnswers++;
        _exerciseResults[_currentExerciseIndex] = true;
      } else {
        _exerciseResults[_currentExerciseIndex] = false;
      }

      if (mounted) {
        setState(() {
          _evaluationData = response.data;
          _isEvaluating = false;
          _currentExerciseIndex++;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _nextButtonFocusNode.requestFocus();
        });
      }
    } catch (e) {
      debugPrint("Error evaluating challenge: $e");
      if (mounted) {
        setState(() => _isEvaluating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al evaluar: $e')),
        );
      }
    }
  }

  void _useWildcardForCurrentExercise() {
    if (_wildcardsRemaining <= 0 || _usedWildcardForCurrentExercise || _evaluationData == null) return;

    setState(() {
      _wildcardsRemaining--;
      _usedWildcardForCurrentExercise = true;
      _correctAnswers++;
      if (_currentExerciseIndex > 0) {
        _exerciseResults[_currentExerciseIndex - 1] = true;
      }
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.amber.shade900,
        content: const Row(
          children: [
            Text("🛡️", style: TextStyle(fontSize: 18)),
            SizedBox(width: 8),
            Text(
              "¡Comodín aplicado! Este ejercicio se contó como correcto.",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finishSession() async {
    setState(() => _isLoading = true);
    final double precisionScore = (_correctAnswers / _totalExercises) * 100;
    
    try {
      final notifier = ref.read(ieltsPathProvider.notifier);
      final result = await notifier.completeUnit(widget.level, widget.unit, precisionScore);
      
      if (mounted) {
        setState(() => _isLoading = false);
        if (result != null && result.unlockedNext) {
          _confettiController.play();
        }
        _showResultsDialog(precisionScore, result?.unlockedNext ?? false);
      }
    } catch (e) {
      debugPrint("Error finishing session: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showResultsDialog(double score, bool unlockedNext) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardGrey,
          title: Text(
            score >= 80 ? '¡Unidad IELTS Completada!' : 'Buen intento',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Precisión: ${score.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: score >= 80 ? Colors.greenAccent : Colors.amber, 
                  fontSize: 32, 
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 16),
              if (unlockedNext)
                const Text(
                  '¡Has desbloqueado la siguiente unidad de IELTS!',
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                )
              else if (score < 80)
                const Text(
                  'Necesitas un 80% o más para dominar esta unidad.',
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
          actions: [
            if (score < 80)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _currentExerciseIndex = 0;
                    _correctAnswers = 0;
                    _wildcardsRemaining = 3;
                    _usedWildcardForCurrentExercise = false;
                    _exerciseResults = List.filled(10, null);
                  });
                  _loadChallenge();
                },
                child: const Text('Volver a Intentarlo', style: TextStyle(color: Colors.amber, fontSize: 16)),
              ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Volver a la Guía IELTS', style: TextStyle(color: AppColors.primaryBlue, fontSize: 16)),
            ),
          ],
        );
      }
    );
  }

  void _showTheoryModal() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardGrey,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return FutureBuilder<Map<String, dynamic>>(
              future: ref.read(ieltsPathServiceProvider).getUnitContent(widget.level, widget.unit),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Center(child: Text("Error al cargar la teoría.", style: TextStyle(color: Colors.redAccent)));
                }

                final markdownText = snapshot.data!['markdown'] as String? ?? "Sin teoría disponible.";
                final title = snapshot.data!['title'] as String? ?? widget.unitTitle;

                return Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const Divider(color: Colors.white10, height: 24),
                      Expanded(
                        child: Markdown(
                          controller: scrollController,
                          data: markdownText,
                          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                            p: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
                            h1: const TextStyle(color: Colors.amber, fontSize: 22, fontWeight: FontWeight.bold),
                            h2: const TextStyle(color: Colors.purpleAccent, fontSize: 18, fontWeight: FontWeight.bold),
                            h3: const TextStyle(color: Colors.lightBlueAccent, fontSize: 16, fontWeight: FontWeight.bold),
                            code: const TextStyle(color: Colors.greenAccent, backgroundColor: Colors.black26),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (_currentExerciseIndex / _totalExercises);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(widget.unitTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Marcador de Penales (Penalty Shootout Tracker)
                      _buildPenaltyShootoutTracker(),
                      const SizedBox(height: 14),

                      // Barra de Progreso
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Colors.white10,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tarjeta de Ejercicio
                      _buildChallengeCard(),
                    ],
                  ),
                ),

          // Confeti al finalizar
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.purple, Colors.amber],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard() {
    if (_challengeData == null) return const SizedBox.shrink();

    final contextDesc = _challengeData!['context']?.toString() ?? "Contexto";
    final spanishSentence = _challengeData!['spanish_sentence']?.toString() ?? "";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sub-header de nivel / ejercicio / comodines / teoría
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Oración ${(_currentExerciseIndex + 1).clamp(1, _totalExercises)} de $_totalExercises',
                style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  // Wildcard badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Text("🛡️", style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 4),
                        Text(
                          "$_wildcardsRemaining/3",
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: _showTheoryModal,
                    child: const Row(
                      children: [
                        Text("Teoría", style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
                        SizedBox(width: 4),
                        Icon(Icons.auto_stories, color: Colors.amber, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            contextDesc,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
          ),
          const SizedBox(height: 16),
          const Text(
            "Traduce la siguiente oración:",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            "\"$spanishSentence\"",
            style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _textController,
            focusNode: _inputFocusNode,
            enabled: _evaluationData == null && !_isEvaluating,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            onSubmitted: (_) {
              if (_evaluationData == null) _evaluateTranslation();
            },
            decoration: InputDecoration(
              hintText: "Escribe tu traducción en inglés...",
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
              filled: true,
              fillColor: const Color(0xFF2A2A3D),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),
          if (_evaluationData == null) ...[
            ElevatedButton(
              onPressed: _isEvaluating ? null : _evaluateTranslation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isEvaluating 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("Comprobar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 24),
            _buildDeepLTranslatorSection(),
          ],
          if (_evaluationData != null) ...[
            _buildFeedbackSection(),
            const SizedBox(height: 20),
            ElevatedButton(
              focusNode: _nextButtonFocusNode,
              onPressed: _loadChallenge,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent.shade700,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Siguiente Oración ➔", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildDeepLTranslatorSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.g_translate, color: Colors.blueAccent, size: 18),
                  SizedBox(width: 6),
                  Text(
                    "Asistente Traducción DeepL",
                    style: TextStyle(color: Colors.blueAccent, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _deeplTargetLang,
                    dropdownColor: AppColors.cardGrey,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    items: const [
                      DropdownMenuItem(value: "EN-US", child: Text("US 🇺🇸")),
                      DropdownMenuItem(value: "EN-GB", child: Text("UK 🇬🇧")),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _deeplTargetLang = val;
                        });
                        if (_deeplSpanishController.text.isNotEmpty) {
                          _translateWithDeepL();
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Español", style: TextStyle(color: Colors.white54, fontSize: 11)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _deeplSpanishController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: "Escribe palabra o frase...",
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFF2A2A3D),
                        contentPadding: const EdgeInsets.all(10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                      onSubmitted: (_) => _translateWithDeepL(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: IconButton(
                  onPressed: _isTranslatingDeepL ? null : _translateWithDeepL,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: _isTranslatingDeepL
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _deeplTargetLang == "EN-GB" ? "Inglés (UK)" : "Inglés (US)",
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 58),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A3D),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: _deeplEnglishResult.isNotEmpty
                          ? Text(
                              _deeplEnglishResult,
                              style: const TextStyle(color: Colors.greenAccent, fontSize: 14, fontWeight: FontWeight.w600),
                            )
                          : Text(
                              "Traducción...",
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 13),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_deeplEnglishResult.isNotEmpty && _deeplEnglishResult != "Error al traducir.") ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: (_isSavingDeepLVocab || _deeplSavedInVocab) ? null : _saveDeepLToVocabulary,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _deeplSavedInVocab ? Colors.green.withValues(alpha: 0.2) : Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _deeplSavedInVocab ? Colors.greenAccent : Colors.amber.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isSavingDeepLVocab)
                        const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(color: Colors.amber, strokeWidth: 2))
                      else
                        Icon(
                          _deeplSavedInVocab ? Icons.check_circle : Icons.bookmark_add,
                          color: _deeplSavedInVocab ? Colors.greenAccent : Colors.amber,
                          size: 15,
                        ),
                      const SizedBox(width: 6),
                      Text(
                        _deeplSavedInVocab ? "Guardada en Vocabulario" : "Guardar en Vocabulario",
                        style: TextStyle(
                          color: _deeplSavedInVocab ? Colors.greenAccent : Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeedbackSection() {
    final feedbackText = _evaluationData!['feedback_text'] as String? ?? "";
    final diffs = _evaluationData!['differences'] as List? ?? [];
    final errorsFound = _evaluationData!['errors_found'] as List? ?? [];

    final rawIsPerfect = diffs.every((d) => d['type'] == 'default');
    final isPerfect = rawIsPerfect || _usedWildcardForCurrentExercise;
    final isStylisticOnly = errorsFound.isNotEmpty && errorsFound.every((e) => e['category'] == 'StylisticSuggestion');

    Color cardBorderColor;
    String statusTitle;

    if (_usedWildcardForCurrentExercise) {
      cardBorderColor = Colors.amber;
      statusTitle = "¡Rescatado con Comodín! 🛡️ (Contado como Correcto)";
    } else if (isPerfect) {
      cardBorderColor = Colors.green;
      statusTitle = "¡Perfecto!";
    } else if (isStylisticOnly) {
      cardBorderColor = Colors.amber;
      statusTitle = "Sugerencia de Fluidez:";
    } else {
      cardBorderColor = Colors.redAccent.withValues(alpha: 0.5);
      statusTitle = "Corrección:";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cardBorderColor, width: _usedWildcardForCurrentExercise ? 1.5 : 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                statusTitle,
                style: TextStyle(
                  color: _usedWildcardForCurrentExercise ? Colors.amber : Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 18, color: Colors.white, height: 1.5),
                  children: diffs.map((diff) {
                    final type = diff['type'];
                    final text = (diff['text'] ?? "") + " ";

                    if (_usedWildcardForCurrentExercise) {
                      // If wildcard used, present all as accepted green text
                      return TextSpan(
                        text: text,
                        style: const TextStyle(color: Colors.white),
                      );
                    }

                    if (type == 'removed') {
                      return TextSpan(
                        text: text,
                        style: TextStyle(
                          color: isStylisticOnly ? Colors.orangeAccent : Colors.redAccent,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: isStylisticOnly ? Colors.orangeAccent : Colors.redAccent,
                          decorationThickness: 2.0,
                        ),
                      );
                    } else if (type == 'added') {
                      return TextSpan(
                        text: text,
                        style: TextStyle(
                          color: isStylisticOnly ? Colors.amberAccent : Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }
                    return TextSpan(text: text);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Wildcard button (if exercise was NOT perfect and wildcard hasn't been used yet)
        if (!rawIsPerfect && !_usedWildcardForCurrentExercise && _wildcardsRemaining > 0) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _useWildcardForCurrentExercise,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.amber, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: Colors.amber.withValues(alpha: 0.1),
            ),
            icon: const Text("🛡️", style: TextStyle(fontSize: 16)),
            label: Text(
              "Usar Comodín por Typo ($_wildcardsRemaining disponible${_wildcardsRemaining > 1 ? 's' : ''})",
              style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],

        if (feedbackText.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.school, color: AppColors.primaryBlue, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    feedbackText,
                    style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _translateWithDeepL() async {
    final text = _deeplSpanishController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isTranslatingDeepL = true;
      _deeplSavedInVocab = false;
    });

    try {
      final service = ref.read(ieltsPathServiceProvider);
      final res = await service.translateWithDeepL(text, _deeplTargetLang);
      if (mounted) {
        setState(() {
          _deeplEnglishResult = res['translated_text']?.toString() ?? res['translatedText']?.toString() ?? "";
          _isTranslatingDeepL = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _deeplEnglishResult = "Error al traducir.";
          _isTranslatingDeepL = false;
        });
      }
    }
  }

  Future<void> _saveDeepLToVocabulary() async {
    final spanishText = _deeplSpanishController.text.trim();
    final englishText = _deeplEnglishResult.trim();
    if (spanishText.isEmpty || englishText.isEmpty || englishText == "Error al traducir.") return;

    setState(() => _isSavingDeepLVocab = true);

    final spaSentence = _challengeData?['spanish_sentence']?.toString() ?? "";
    final engSentence = _challengeData?['ideal_english_translation']?.toString() ?? "";
    
    String contextSentence = widget.unitTitle;
    if (spaSentence.isNotEmpty && engSentence.isNotEmpty) {
      contextSentence = "ES: $spaSentence | EN: $engSentence";
    } else if (spaSentence.isNotEmpty) {
      contextSentence = spaSentence;
    }

    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.dio.post(
        '/learning-analysis/vocabulary',
        data: {
          "spanish_word": spanishText,
          "english_word": englishText,
          "context_sentence": contextSentence,
        },
      );

      if (mounted) {
        setState(() {
          _isSavingDeepLVocab = false;
          _deeplSavedInVocab = true;
        });
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text("¡Palabra guardada en Vocabulario!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSavingDeepLVocab = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar en vocabulario: $e')),
        );
      }
    }
  }

  Widget _buildPenaltyShootoutTracker() {
    final int correct = _exerciseResults.where((r) => r == true).length;
    final int incorrect = _exerciseResults.where((r) => r == false).length;
    final int pending = _exerciseResults.where((r) => r == null).length;

    // Active index: if we are evaluating / showing feedback, the current active dot is _currentExerciseIndex - 1
    // if waiting for input, active dot is _currentExerciseIndex
    final int activeIndex = (_evaluationData != null && _currentExerciseIndex > 0)
        ? _currentExerciseIndex - 1
        : _currentExerciseIndex.clamp(0, _totalExercises - 1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Resumen de Marcador (Chips)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTallyChip(
                icon: Icons.check_circle,
                label: "$correct Correctas",
                color: Colors.greenAccent.shade400,
                bg: Colors.green.withValues(alpha: 0.15),
              ),
              const SizedBox(width: 8),
              _buildTallyChip(
                icon: Icons.cancel,
                label: "$incorrect Errores",
                color: Colors.redAccent.shade200,
                bg: Colors.red.withValues(alpha: 0.15),
              ),
              const SizedBox(width: 8),
              _buildTallyChip(
                icon: Icons.hourglass_top,
                label: "$pending Restantes",
                color: Colors.white70,
                bg: Colors.white.withValues(alpha: 0.08),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Fila de Penales (10 Dots / Badges)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_totalExercises, (index) {
                final result = _exerciseResults[index];
                final bool isActive = (index == activeIndex && _currentExerciseIndex < _totalExercises);

                Color dotColor;
                Color borderColor;
                Widget childWidget;

                if (result == true) {
                  dotColor = const Color(0xFF10B981); // Emerald Green
                  borderColor = Colors.greenAccent;
                  childWidget = const Icon(Icons.check, color: Colors.white, size: 14);
                } else if (result == false) {
                  dotColor = const Color(0xFFEF4444); // Red
                  borderColor = Colors.redAccent;
                  childWidget = const Icon(Icons.close, color: Colors.white, size: 14);
                } else if (isActive) {
                  dotColor = Colors.amber.withValues(alpha: 0.25);
                  borderColor = Colors.amber;
                  childWidget = Text(
                    '${index + 1}',
                    style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                  );
                } else {
                  dotColor = Colors.white.withValues(alpha: 0.05);
                  borderColor = Colors.white12;
                  childWidget = Text(
                    '${index + 1}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11),
                  );
                }

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 34 : 28,
                  height: isActive ? 34 : 28,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: borderColor,
                      width: isActive ? 2.5 : 1.5,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: Colors.amber.withValues(alpha: 0.4),
                              blurRadius: 6,
                              spreadRadius: 1,
                            )
                          ]
                        : null,
                  ),
                  child: Center(child: childWidget),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTallyChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
