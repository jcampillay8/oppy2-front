import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';

class AddVocabularyWordScreen extends ConsumerStatefulWidget {
  const AddVocabularyWordScreen({super.key});

  @override
  ConsumerState<AddVocabularyWordScreen> createState() => _AddVocabularyWordScreenState();
}

class _AddVocabularyWordScreenState extends ConsumerState<AddVocabularyWordScreen> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isSpanishToEnglish = true;
  bool _isTranslating = false;
  bool _isSaving = false;

  String? _translatedText;
  String? _detectedLang;
  Map<String, dynamic>? _savedWordData;

  Future<void> _translateText() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isTranslating = true;
      _translatedText = null;
      _savedWordData = null;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.dio.post(
        '/learning-analysis/deepl/translate',
        data: {
          "text": text,
          "targetLang": _isSpanishToEnglish ? "EN-US" : "ES",
        },
      );

      if (mounted) {
        setState(() {
          _translatedText = response.data['translatedText'];
          _detectedLang = response.data['detectedSourceLang'];
          _isTranslating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTranslating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al traducir: $e')),
        );
      }
    }
  }

  Future<void> _saveWord() async {
    final originalText = _inputController.text.trim();
    final translated = _translatedText?.trim();

    if (originalText.isEmpty || translated == null || translated.isEmpty) return;

    setState(() => _isSaving = true);

    final String spanishWord = _isSpanishToEnglish ? originalText : translated;
    final String englishWord = _isSpanishToEnglish ? translated : originalText;

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.dio.post(
        '/learning-analysis/vocabulary',
        data: {
          "spanish_word": spanishWord,
          "english_word": englishWord,
          "context_sentence": null, // El backend generará la oración de contexto con IA
        },
      );

      if (mounted) {
        setState(() {
          _savedWordData = response.data as Map<String, dynamic>;
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text("¡Palabra guardada con éxito!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar palabra: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text("Agregar Nueva Palabra", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Direction Selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A3D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSpanishToEnglish = true;
                          _translatedText = null;
                          _savedWordData = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _isSpanishToEnglish ? AppColors.primaryBlue : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "🇪🇸 Español ➔ 🇬🇧 Inglés",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSpanishToEnglish = false;
                          _translatedText = null;
                          _savedWordData = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_isSpanishToEnglish ? AppColors.primaryBlue : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "🇬🇧 Inglés ➔ 🇪🇸 Español",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Text Input
            TextField(
              controller: _inputController,
              focusNode: _focusNode,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              maxLines: 2,
              minLines: 1,
              decoration: InputDecoration(
                hintText: _isSpanishToEnglish
                    ? "Escribe la palabra o frase en Español..."
                    : "Escribe la palabra o frase en Inglés...",
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF2A2A3D),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                ),
                suffixIcon: _inputController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _inputController.clear();
                          setState(() {
                            _translatedText = null;
                            _savedWordData = null;
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _translateText(),
            ),
            const SizedBox(height: 16),

            // Translate Button
            ElevatedButton.icon(
              onPressed: _isTranslating || _inputController.text.trim().isEmpty ? null : _translateText,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: _isTranslating
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.g_translate, color: Colors.white),
              label: const Text("Traducir con DeepL", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),

            const SizedBox(height: 24),

            // Translation Result Card
            if (_translatedText != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A3D),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Traducción obtenida:",
                          style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        if (_detectedLang != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "Origen: $_detectedLang",
                              style: const TextStyle(color: Colors.white70, fontSize: 10),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _translatedText!,
                      style: const TextStyle(color: Colors.greenAccent, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveWord,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: _isSaving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.bookmark_add, color: Colors.white),
                      label: const Text("💾 Guardar en mi Vocabulario", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],

            // Saved Word Card Preview (With AI generated sentence)
            if (_savedWordData != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.purpleAccent),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.purpleAccent, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Oración de ejemplo generada por IA:",
                          style: TextStyle(color: Colors.purpleAccent, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "${_savedWordData!['spanish_word']} ➔ ${_savedWordData!['english_word']}",
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _savedWordData!['context_sentence'] ?? "Sin oración de contexto.",
                        style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
