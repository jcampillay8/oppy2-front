import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';
import '../providers/ielts_path_provider.dart';
import '../services/ielts_path_service.dart';

class IeltsListeningPracticeScreen extends ConsumerStatefulWidget {
  final int level;
  final int unit;
  final String unitTitle;

  const IeltsListeningPracticeScreen({
    super.key,
    required this.level,
    required this.unit,
    required this.unitTitle,
  });

  @override
  ConsumerState<IeltsListeningPracticeScreen> createState() => _IeltsListeningPracticeScreenState();
}

class _IeltsListeningPracticeScreenState extends ConsumerState<IeltsListeningPracticeScreen> {
  final int _totalExercises = 10;
  int _currentExerciseIndex = 0;
  int _correctAnswers = 0;
  int _wildcardsRemaining = 3;
  bool _usedWildcardForCurrentExercise = false;
  List<bool?> _exerciseResults = List.filled(10, null);

  bool _isLoading = true;
  bool _isEvaluating = false;
  bool _isPlayingAudio = false;
  double _playbackRate = 1.0; // 1.0x o 0.8x

  Map<String, dynamic>? _challengeData;
  Map<String, dynamic>? _evaluationData;

  final AudioPlayer _audioPlayer = AudioPlayer();
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

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlayingAudio = (state == PlayerState.playing);
        });
      }
    });

    _loadChallenge();
  }

  @override
  void dispose() {
    _webAudioElement?.pause();
    _audioPlayer.stop();
    _audioPlayer.dispose();
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
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.dio.post(
        '/learning-analysis/ielts-listening/challenge/generate',
        queryParameters: {
          "level": widget.level,
          "unit": widget.unit,
        },
      );

      if (mounted) {
        setState(() {
          _challengeData = response.data;
          _isLoading = false;
        });

        // Reproducir audio automáticamente al cargar la pregunta
        _playAudio();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _inputFocusNode.requestFocus();
        });
      }
    } catch (e) {
      debugPrint("Error loading Listening challenge: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar ejercicio de escucha: $e')),
        );
      }
    }
  }

  html.AudioElement? _webAudioElement;

  Future<void> _playAudio() async {
    if (_challengeData == null) return;
    String audioBase64 = _challengeData!['audio_base64']?.toString() ?? "";
    if (audioBase64.isEmpty) return;

    if (!audioBase64.startsWith("data:")) {
      audioBase64 = "data:audio/mp3;base64,$audioBase64";
    }

    if (kIsWeb) {
      try {
        _webAudioElement?.pause();
        _webAudioElement = html.AudioElement(audioBase64);
        _webAudioElement!.playbackRate = _playbackRate;
        setState(() => _isPlayingAudio = true);
        _webAudioElement!.onEnded.listen((_) {
          if (mounted) setState(() => _isPlayingAudio = false);
        });
        _webAudioElement!.play().catchError((e) {
          debugPrint("Audio play promise interrupted: $e");
        });
        return;
      } catch (e) {
        debugPrint("HTML AudioElement error: $e");
      }
    }

    try {
      await _audioPlayer.stop();
      try {
        await _audioPlayer.setPlaybackRate(_playbackRate);
      } catch (_) {}
      await _audioPlayer.play(UrlSource(audioBase64));
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  void _togglePlaybackRate() {
    setState(() {
      _playbackRate = (_playbackRate == 1.0) ? 0.8 : 1.0;
    });
    _playAudio();
  }

  Future<void> _evaluateTranscription() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _challengeData == null) return;

    setState(() => _isEvaluating = true);

    try {
      final apiClient = ref.read(apiClientProvider);
      final targetSentence = _challengeData!['english_sentence']?.toString() ?? "";
      
      final response = await apiClient.dio.post(
        '/learning-analysis/ielts-listening/evaluate',
        data: {
          "user_translation": text,
          "grammar_target": _challengeData!['grammar_target'],
          "spanish_sentence": targetSentence
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
      debugPrint("Error evaluating listening challenge: $e");
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
      const SnackBar(
        backgroundColor: Color(0xFF0C4A6E),
        content: Row(
          children: [
            Text("🛡️", style: TextStyle(fontSize: 18)),
            SizedBox(width: 8),
            Text(
              "¡Comodín aplicado! Ejercicio contado como correcto.",
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
      debugPrint("Error finishing listening session: $e");
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
            score >= 80 ? '¡Listening IELTS Completado!' : 'Buen intento',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Precisión: ${score.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: score >= 80 ? const Color(0xFF38BDF8) : Colors.amber,
                  fontSize: 32,
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 16),
              if (unlockedNext)
                const Text(
                  '¡Has desbloqueado la siguiente unidad de Listening!',
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                )
              else if (score < 80)
                const Text(
                  'Necesitas un 80% o más para dominar esta lección auditiva.',
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
              child: const Text('Volver a Listening IELTS', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 16)),
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
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)));
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
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const Divider(color: Colors.white10, height: 24),
                      Expanded(
                        child: Markdown(
                          controller: scrollController,
                          data: markdownText,
                          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                            p: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
                            h1: const TextStyle(color: Color(0xFF38BDF8), fontSize: 22, fontWeight: FontWeight.bold),
                            h2: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
                            h3: const TextStyle(color: Colors.lightBlueAccent, fontSize: 16, fontWeight: FontWeight.bold),
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
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
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
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tarjeta de Ejercicio Listening
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
              colors: const [Color(0xFF38BDF8), Colors.blue, Colors.amber, Colors.greenAccent],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard() {
    if (_challengeData == null) return const SizedBox.shrink();

    final contextDesc = _challengeData!['context']?.toString() ?? "Contexto";
    final voiceName = _challengeData!['voice_name']?.toString() ?? "en-US-Standard-E";
    final voiceGender = _challengeData!['voice_gender']?.toString() ?? "Female";
    final targetSentence = _challengeData!['english_sentence']?.toString() ?? "";

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
          // Sub-header: ejercicio / comodines / teoría
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Oración ${(_currentExerciseIndex + 1).clamp(1, _totalExercises)} de $_totalExercises',
                style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
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
                          style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
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
          const SizedBox(height: 20),

          // Tarjeta de Control del Reproductor de Audio
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0EA5E9).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Insignia de Voz
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            voiceGender == "Female" ? Icons.female : Icons.male,
                            color: const Color(0xFF38BDF8),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Voz $voiceGender ($voiceName)",
                            style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),

                    // Toggle de Velocidad (1.0x / 0.8x Lento)
                    InkWell(
                      onTap: _togglePlaybackRate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _playbackRate < 1.0 ? Colors.amber.withValues(alpha: 0.25) : Colors.white10,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _playbackRate < 1.0 ? Colors.amber : Colors.white24,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.speed, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              _playbackRate == 1.0 ? "1.0x (Normal)" : "0.8x (Lento)",
                              style: TextStyle(
                                color: _playbackRate < 1.0 ? Colors.amber : Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Botón Gigante de Reproducción
                ElevatedButton.icon(
                  onPressed: _playAudio,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  icon: Icon(
                    _isPlayingAudio ? Icons.volume_up : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  label: Text(
                    _isPlayingAudio ? "Escuchando..." : "Escuchar Audio",
                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Campo de Transcripción
          const Text(
            "Escribe lo que escuchaste en inglés:",
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _textController,
            focusNode: _inputFocusNode,
            enabled: _evaluationData == null && !_isEvaluating,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            onSubmitted: (_) {
              if (_evaluationData == null) _evaluateTranscription();
            },
            decoration: InputDecoration(
              hintText: "Escribe la oración exacta en inglés...",
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
              filled: true,
              fillColor: const Color(0xFF2A2A3D),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),

          if (_evaluationData == null) ...[
            ElevatedButton(
              onPressed: _isEvaluating ? null : _evaluateTranscription,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isEvaluating
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("Comprobar Transcripción", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 24),
            _buildDeepLTranslatorSection(),
          ],

          if (_evaluationData != null) ...[
            // Revelar Oración Objetivo Original
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0EA5E9).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Oración Original en Inglés:",
                        style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      IconButton(
                        onPressed: _playAudio,
                        icon: const Icon(Icons.volume_up, color: Color(0xFF38BDF8), size: 20),
                        tooltip: "Re-escuchar Audio",
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "\"$targetSentence\"",
                    style: const TextStyle(color: Colors.amber, fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

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
              child: const Text("Siguiente Ejercicio ➔", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeedbackSection() {
    if (_evaluationData == null) return const SizedBox.shrink();

    final diffs = (_evaluationData!['differences'] as List? ?? []);
    final feedbackText = _evaluationData!['feedback_text']?.toString() ?? "";
    final errorsFound = (_evaluationData!['errors_found'] as List? ?? []);
    final isFluencySuggestionOnly = errorsFound.isNotEmpty &&
        errorsFound.every((e) => e['category'] == 'StylisticSuggestion');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Caja de Diferencias
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isFluencySuggestionOnly ? Colors.amber : (diffs.every((d) => d['type'] == 'default') ? Colors.greenAccent : Colors.redAccent),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isFluencySuggestionOnly ? "Sugerencia de Fluidez:" : "Comparativa de Transcripción:",
                style: TextStyle(
                  color: isFluencySuggestionOnly ? Colors.amber : Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  children: diffs.map<InlineSpan>((d) {
                    final type = d['type']?.toString() ?? 'default';
                    final text = "${d['text']?.toString() ?? ''} ";

                    if (type == 'removed') {
                      return TextSpan(
                        text: text,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          decoration: TextDecoration.lineThrough,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      );
                    } else if (type == 'added') {
                      return TextSpan(
                        text: text,
                        style: TextStyle(
                          color: isFluencySuggestionOnly ? Colors.amber : Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      );
                    }
                    return TextSpan(
                      text: text,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Tarjeta Azul de Lección
        if (feedbackText.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("🎓", style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    feedbackText,
                    style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                  ),
                ),
              ],
            ),
          ),

        if (!errorsFound.every((e) => e['category'] == 'StylisticSuggestion') && errorsFound.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: OutlinedButton.icon(
              onPressed: _usedWildcardForCurrentExercise ? null : _useWildcardForCurrentExercise,
              icon: const Text("🛡️", style: TextStyle(fontSize: 16)),
              label: Text(
                _usedWildcardForCurrentExercise ? "Comodín Aplicado" : "Usar Comodín por Typo ($_wildcardsRemaining disponibles)",
                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.amber),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
      ],
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
                    isDense: true,
                    style: const TextStyle(color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.bold),
                    items: const [
                      DropdownMenuItem(value: "EN-US", child: Text("EN")),
                      DropdownMenuItem(value: "ES", child: Text("ES")),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _deeplTargetLang = val);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _deeplSpanishController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: "Consulta una palabra o frase...",
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 13),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    filled: true,
                    fillColor: Colors.black12,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isTranslatingDeepL ? null : _translateWithDeepL,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isTranslatingDeepL
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.search, color: Colors.white, size: 18),
              ),
            ],
          ),
          if (_deeplEnglishResult.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _deeplEnglishResult,
                      style: const TextStyle(color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: _deeplSavedInVocab || _isSavingDeepLVocab ? null : _saveDeepLToVocabulary,
                    icon: Icon(
                      _deeplSavedInVocab ? Icons.bookmark_added : Icons.bookmark_add_outlined,
                      color: _deeplSavedInVocab ? Colors.amber : Colors.white70,
                      size: 20,
                    ),
                    tooltip: "Guardar en mi Vocabulario",
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
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

    final engSentence = _challengeData?['english_sentence']?.toString() ?? "";
    String contextSentence = widget.unitTitle;
    if (engSentence.isNotEmpty) {
      contextSentence = "EN: $engSentence";
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

    final int activeIndex = (_evaluationData != null && _currentExerciseIndex > 0)
        ? _currentExerciseIndex - 1
        : _currentExerciseIndex.clamp(0, _totalExercises - 1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
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
                  dotColor = const Color(0xFF10B981);
                  borderColor = Colors.greenAccent;
                  childWidget = const Icon(Icons.check, color: Colors.white, size: 14);
                } else if (result == false) {
                  dotColor = const Color(0xFFEF4444);
                  borderColor = Colors.redAccent;
                  childWidget = const Icon(Icons.close, color: Colors.white, size: 14);
                } else if (isActive) {
                  dotColor = const Color(0xFF0EA5E9).withValues(alpha: 0.25);
                  borderColor = const Color(0xFF38BDF8);
                  childWidget = Text(
                    '${index + 1}',
                    style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 12),
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
                    border: Border.all(color: borderColor, width: isActive ? 2.5 : 1.5),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
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
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
