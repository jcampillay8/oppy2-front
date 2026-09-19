import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';
import '../widgets/ielts_activity_heatmap_sheet.dart';
import 'vocabulary_practice_screen.dart';
import 'add_vocabulary_word_screen.dart';

class VocabularyMainMenuScreen extends ConsumerStatefulWidget {
  const VocabularyMainMenuScreen({super.key});

  @override
  ConsumerState<VocabularyMainMenuScreen> createState() => _VocabularyMainMenuScreenState();
}

class _VocabularyMainMenuScreenState extends ConsumerState<VocabularyMainMenuScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _activityStats;
  Map<String, dynamic>? _vocabStats;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final apiClient = ref.read(apiClientProvider);

      final activityRes = await apiClient.dio.get('/learning-analysis/ielts-path/activity');
      final vocabRes = await apiClient.dio.get('/learning-analysis/vocabulary/stats');

      if (mounted) {
        setState(() {
          _activityStats = activityRes.data as Map<String, dynamic>?;
          _vocabStats = vocabRes.data as Map<String, dynamic>?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showHeatmapModal() {
    if (_activityStats == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => IeltsActivityHeatmapSheet(stats: _activityStats!),
    );
  }

  Future<List<dynamic>> _fetchUserVocabularyList() async {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.dio.get('/learning-analysis/vocabulary/list');
    return response.data as List<dynamic>;
  }

  Future<void> _deleteWord(int wordId, StateSetter setModalState) async {
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
                Text("Palabra eliminada.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      }
      setModalState(() {});
      _loadDashboardData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
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
                                "No tienes palabras guardadas aún.\nUsa la opción 'Agregar Nuevas Palabras' para comenzar.",
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
                                      onPressed: () => _deleteWord(wordId, setModalState),
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

  @override
  Widget build(BuildContext context) {
    final currentStreak = _activityStats?['current_streak'] ?? 0;
    final inReviewCount = _vocabStats?['in_review'] ?? 0;
    final masteredCount = _vocabStats?['mastered'] ?? 0;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text("Vocabulario", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              color: AppColors.primaryBlue,
              child: SingleChildScrollView(

          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header de Days of Streak
              InkWell(
                onTap: _showHeatmapModal,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A3D),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.5), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Text("🔥", style: TextStyle(fontSize: 26)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$currentStreak Días de Racha",
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "Toca para ver tu Heatmap y métricas",
                              style: TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white54),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tarjetas de KPIs (En Repaso & Dominadas)
              Row(
                children: [
                  Expanded(
                    child: _buildKpiCard(
                      title: "En Repaso",
                      count: "$inReviewCount",
                      icon: Icons.style,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildKpiCard(
                      title: "Dominadas",
                      count: "$masteredCount",
                      icon: Icons.emoji_events,
                      color: Colors.greenAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                "¿Qué deseas hacer hoy?",
                style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // 1. Comenzar Práctica de Vocabulario
              _buildMenuCard(
                title: "Comenzar Práctica de Vocabulario",
                subtitle: "Practica con temporizador contra reloj (SRS)",
                icon: Icons.play_circle_fill,
                color: AppColors.primaryBlue,
                isPrimary: true,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VocabularyPracticeScreen()),
                  );
                  _loadDashboardData();
                },
              ),
              const SizedBox(height: 14),

              // 2. Agregar Nuevas Palabras
              _buildMenuCard(
                title: "Agregar Nuevas Palabras",
                subtitle: "Traduce con DeepL y genera oraciones con IA",
                icon: Icons.add_circle,
                color: Colors.greenAccent,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddVocabularyWordScreen()),
                  );
                  _loadDashboardData();
                },
              ),
              const SizedBox(height: 14),

              // 3. Mis Palabras Guardadas
              _buildMenuCard(
                title: "Mis Palabras Guardadas",
                subtitle: "Revisa tu lista completa y estado de dominio",
                icon: Icons.bookmarks,
                color: Colors.purpleAccent,
                onTap: _showVocabularyListModal,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isPrimary ? color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
            border: Border.all(
              color: isPrimary ? color.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.1),
              width: isPrimary ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
