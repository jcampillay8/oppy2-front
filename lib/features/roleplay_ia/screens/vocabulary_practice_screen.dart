import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';

class VocabularyPracticeScreen extends ConsumerStatefulWidget {
  const VocabularyPracticeScreen({super.key});

  @override
  ConsumerState<VocabularyPracticeScreen> createState() => _VocabularyPracticeScreenState();
}

class _VocabularyPracticeScreenState extends ConsumerState<VocabularyPracticeScreen> {
  bool _isLoading = true;
  bool _isEvaluating = false;
  Map<String, dynamic>? _wordData;
  Map<String, dynamic>? _resultData;
  
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FocusNode _nextButtonFocusNode = FocusNode();
  final FocusNode _keyboardFocusNode = FocusNode();
  
  // Timer logic
  Timer? _timer;
  int _timeLeft = 15;
  static const int _maxTime = 15;
  
  // Practice Direction logic: "BOTH" (50/50), "ES_TO_EN", "EN_TO_ES"
  String _practiceDirection = "BOTH";
  bool _isSpanishToEnglish = true;

  @override
  void initState() {
    super.initState();
    _loadNextWord();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _timeLeft = _maxTime);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _resultData != null) {
        timer.cancel();
        return;
      }
      
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          timer.cancel();
          _handleTimeout();
        }
      });
    });
  }

  Future<void> _loadNextWord() async {
    _timer?.cancel();
    setState(() {
      _isLoading = true;
      _resultData = null;
      _wordData = null;
      _textController.clear();

      if (_practiceDirection == "ES_TO_EN") {
        _isSpanishToEnglish = true;
      } else if (_practiceDirection == "EN_TO_ES") {
        _isSpanishToEnglish = false;
      } else {
        _isSpanishToEnglish = (DateTime.now().millisecondsSinceEpoch % 2 == 0);
      }
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.dio.get('/learning-analysis/vocabulary/practice');
      
      if (mounted) {
        setState(() {
          _wordData = response.data;
          _isLoading = false;
        });
        
        _startTimer();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _focusNode.requestFocus();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        if (e.toString().contains('404')) {
          // No words to practice
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  Future<void> _handleTimeout() async {
    _textController.text = "_timeout_";
    await _evaluateAnswer();
  }

  Future<void> _evaluateAnswer() async {
    final text = _textController.text.trim();
    if (text.isEmpty && text != "_timeout_") return;
    
    _timer?.cancel();
    setState(() => _isEvaluating = true);

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.dio.post(
        '/learning-analysis/vocabulary/evaluate',
        data: {
          "word_id": _wordData!['id'],
          "user_answer": text,
        }
      );
      
      if (mounted) {
        setState(() {
          _resultData = response.data;
          _isEvaluating = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _nextButtonFocusNode.requestFocus();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isEvaluating = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al evaluar: $e')));
      }
    }
  }

  Future<void> _deleteWord(int wordId) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.dio.delete('/learning-analysis/vocabulary/$wordId');
      
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 2),
            content: Row(
              children: [
                Icon(Icons.delete, color: Colors.white),
                SizedBox(width: 8),
                Text("Palabra eliminada de tu vocabulario.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      }
      _loadNextWord();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar palabra: $e')),
        );
      }
    }
  }

  Future<List<dynamic>> _fetchUserVocabularyList() async {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.dio.get('/learning-analysis/vocabulary/list');
    return response.data as List<dynamic>;
  }

  void _showVocabularyListModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardGrey,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return FutureBuilder<List<dynamic>>(
                  future: _fetchUserVocabularyList(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.redAccent)));
                    }

                    final words = snapshot.data ?? [];

                    return Column(
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "📚 Mis Palabras Guardadas (${words.length})",
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.white70),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),
                        const Divider(color: Colors.white10),
                        if (words.isEmpty)
                          const Expanded(
                            child: Center(
                              child: Text(
                                "No tienes palabras guardadas aún.\nUsa el Asistente DeepL para guardar vocabulario.",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white54),
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: words.length,
                              itemBuilder: (context, index) {
                                final item = words[index] as Map<String, dynamic>;
                                final wordId = item['id'];
                                final spanish = item['spanish_word'] ?? "";
                                final english = item['english_word'] ?? "";
                                final isMastered = item['is_mastered'] ?? false;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2A2A3D),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isMastered ? Colors.green.withValues(alpha: 0.5) : Colors.white10,
                                    ),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      "$spanish ➔ $english",
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    subtitle: isMastered
                                        ? const Text("🏆 Dominada", style: TextStyle(color: Colors.greenAccent, fontSize: 11))
                                        : Text("Nivel de práctica: ${item['score'] ?? 3}", style: const TextStyle(color: Colors.white38, fontSize: 11)),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                                      onPressed: () async {
                                        await _deleteWord(wordId);
                                        setModalState(() {});
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  String _getFormattedContextSentence(
    String rawContext,
    bool isSpanishToEnglish,
    String spanishWord,
    String englishWord,
  ) {
    if (rawContext.isEmpty) return "";

    String resultText = rawContext;

    if (rawContext.contains("ES:") && rawContext.contains("EN:")) {
      final parts = rawContext.split("|");
      final esPart = parts.firstWhere((p) => p.trim().startsWith("ES:"), orElse: () => "").replaceFirst("ES:", "").trim();
      final enPart = parts.firstWhere((p) => p.trim().startsWith("EN:"), orElse: () => "").replaceFirst("EN:", "").trim();

      if (isSpanishToEnglish && esPart.isNotEmpty) {
        resultText = esPart;
      } else if (!isSpanishToEnglish && enPart.isNotEmpty) {
        resultText = enPart;
      }
    }

    // Mask the target word in the context sentence if present to avoid spoiling the answer
    final targetWord = isSpanishToEnglish ? englishWord.trim() : spanishWord.trim();
    if (targetWord.isNotEmpty) {
      final pattern = RegExp(RegExp.escape(targetWord), caseSensitive: false);
      if (pattern.hasMatch(resultText)) {
        resultText = resultText.replaceAll(pattern, "___");
      }
    }

    return resultText;
  }

  Widget _buildModeChip(String key, String label) {
    final isSelected = _practiceDirection == key;
    return InkWell(
      onTap: () {
        if (_practiceDirection != key) {
          setState(() {
            _practiceDirection = key;
          });
          _loadNextWord();
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.25) : Colors.white10,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primaryBlue : Colors.white24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primaryBlue : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textController.dispose();
    _focusNode.dispose();
    _nextButtonFocusNode.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Vocabulario', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmarks, color: Colors.amber),
            tooltip: "Mi Lista de Vocabulario",
            onPressed: _showVocabularyListModal,
          ),
        ],
      ),
      body: KeyboardListener(
        focusNode: _keyboardFocusNode,
        autofocus: true,
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
            if (_resultData != null) {
              _loadNextWord();
            }
          }
        },
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_wordData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text("¡No tienes palabras pendientes!", style: TextStyle(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 8),
            const Text("Añade más vocabulario usando el Asistente DeepL.", style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _showVocabularyListModal,
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.amber)),
              icon: const Icon(Icons.bookmarks, color: Colors.amber),
              label: const Text("Ver Mis Palabras Guardadas", style: TextStyle(color: Colors.amber)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text("Volver al Menú", style: TextStyle(color: Colors.white)),
            )
          ],
        )
      );
    }

    final double progress = _timeLeft / _maxTime;
    final Color timerColor = _timeLeft <= 5 ? Colors.redAccent : AppColors.primaryBlue;
    final rawContext = _wordData!['context_sentence']?.toString() ?? "";
    final spanishWord = _wordData!['spanish_word']?.toString() ?? "";
    final englishWord = _wordData!['english_word']?.toString() ?? "";
    final formattedContext = _getFormattedContextSentence(rawContext, _isSpanishToEnglish, spanishWord, englishWord);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Selector de Modo (Ambas, Esp->Ing, Ing->Esp)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildModeChip("BOTH", "🔀 Ambas (50/50)"),
              const SizedBox(width: 8),
              _buildModeChip("ES_TO_EN", "🇪🇸 ➔ 🇬🇧 Esp a Ing"),
              const SizedBox(width: 8),
              _buildModeChip("EN_TO_ES", "🇬🇧 ➔ 🇪🇸 Ing a Esp"),
            ],
          ),
          const SizedBox(height: 16),

          // Timer Bar & Delete Action Header
          if (_resultData == null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: Colors.black26,
                valueColor: AlwaysStoppedAnimation<Color>(timerColor),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => _deleteWord(_wordData!['id']),
                  child: const Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.redAccent, size: 16),
                      SizedBox(width: 4),
                      Text("Eliminar palabra", style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Text("$_timeLeft s", textAlign: TextAlign.right, style: TextStyle(color: timerColor, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
            
          const SizedBox(height: 24),
          
          // Palabra a traducir
          Text(
            _isSpanishToEnglish ? "Traduce al Inglés:" : "Traduce al Español:",
            style: const TextStyle(color: Colors.white54, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            _isSpanishToEnglish ? _wordData!['spanish_word'] : _wordData!['english_word'],
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          
          if (formattedContext.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      formattedContext,
                      style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 32),
          
          // Input
          TextField(
            controller: _textController,
            focusNode: _focusNode,
            style: const TextStyle(color: Colors.white, fontSize: 24),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: "Escribe aquí...",
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBlue)),
            ),
            enabled: _resultData == null,
            onSubmitted: (_) => _evaluateAnswer(),
          ),
          
          const SizedBox(height: 32),
          
          // Botón / Resultados
          if (_resultData == null)
            ElevatedButton(
              onPressed: _isEvaluating ? null : _evaluateAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isEvaluating 
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("Enviar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            )
          else
            _buildResults(),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final bool isCorrect = _resultData!['is_correct'];
    final bool isMastered = _resultData!['is_mastered'];
    final String feedback = _resultData!['feedback'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isCorrect ? Colors.green.withValues(alpha: 0.2) : Colors.redAccent.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isCorrect ? Colors.green : Colors.redAccent),
          ),
          child: Column(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.redAccent,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                feedback,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              if (!isCorrect) ...[
                const SizedBox(height: 16),
                const Text("La respuesta correcta es:", style: TextStyle(color: Colors.white54)),
                const SizedBox(height: 4),
                Text(
                  _isSpanishToEnglish ? _wordData!['english_word'] : _wordData!['spanish_word'],
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
              if (isMastered) ...[
                const SizedBox(height: 16),
                const Text("🏆 ¡Palabra Dominada!", style: TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold)),
              ]
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        ElevatedButton(
          focusNode: _nextButtonFocusNode,
          autofocus: true,
          onPressed: _loadNextWord,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Siguiente Palabra (Enter ↵)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
      ],
    );
  }
}
