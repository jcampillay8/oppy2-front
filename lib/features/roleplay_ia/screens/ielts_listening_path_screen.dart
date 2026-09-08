import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/ielts_path_provider.dart';
import '../models/learning_path_model.dart';
import 'ielts_listening_practice_screen.dart';
import '../widgets/ielts_activity_heatmap_sheet.dart';

class IeltsListeningPathScreen extends ConsumerStatefulWidget {
  const IeltsListeningPathScreen({super.key});

  @override
  ConsumerState<IeltsListeningPathScreen> createState() => _IeltsListeningPathScreenState();
}

class _IeltsListeningPathScreenState extends ConsumerState<IeltsListeningPathScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(ieltsPathProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Listening IELTS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          stateAsync.maybeWhen(
            data: (data) {
              final streak = data.activityStats['current_streak'] ?? 0;
              return Container(
                margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => IeltsActivityHeatmapSheet(stats: data.activityStats),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0EA5E9).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Text("🎧", style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 4),
                        Text(
                          "${streak}d",
                          style: const TextStyle(
                            color: Color(0xFF38BDF8),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8))),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error al cargar la ruta de Listening: $err', style: const TextStyle(color: Colors.redAccent)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(ieltsPathProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (data) {
          final syllabus = data.syllabus;
          final levelKeys = syllabus.keys.map(int.parse).toList()..sort();

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: levelKeys.length,
            itemBuilder: (context, index) {
              final level = levelKeys[index];
              final levelData = syllabus[level.toString()] as Map<String, dynamic>;
              final levelTitle = levelData['title']?.toString() ?? 'Nivel $level';
              final unitsData = levelData['units'] as Map<String, dynamic>? ?? {};
              final progressList = data.progress.where((p) => p.level == level).toList();

              return _ListeningLevelCard(
                level: level,
                levelTitle: levelTitle,
                unitsData: unitsData,
                progressList: progressList,
              );
            },
          );
        },
      ),
    );
  }
}

class _ListeningLevelCard extends StatefulWidget {
  final int level;
  final String levelTitle;
  final Map<String, dynamic> unitsData;
  final List<LearningPathUnitProgress> progressList;

  const _ListeningLevelCard({
    required this.level,
    required this.levelTitle,
    required this.unitsData,
    required this.progressList,
  });

  @override
  State<_ListeningLevelCard> createState() => _ListeningLevelCardState();
}

class _ListeningLevelCardState extends State<_ListeningLevelCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final unitKeys = widget.unitsData.keys.map(int.parse).toList()..sort();
    final totalUnits = unitKeys.length;

    int masteredUnits = 0;
    for (var u in unitKeys) {
      final prog = widget.progressList.firstWhere(
        (p) => p.unit == u,
        orElse: () => LearningPathUnitProgress(level: widget.level, unit: u, status: 'locked'),
      );
      if (prog.status == 'mastered') masteredUnits++;
    }

    final double progressRatio = totalUnits > 0 ? (masteredUnits / totalUnits) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0EA5E9).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          'Nivel ${widget.level}',
                          style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '$masteredUnits / $totalUnits Dominadas',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Colors.white70,
                            size: 22,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.levelTitle,
                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressRatio,
                      minHeight: 4,
                      backgroundColor: Colors.white10,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                children: unitKeys.map((unit) {
                  final rawUnitInfo = widget.unitsData[unit.toString()];
                  final unitInfo = rawUnitInfo != null ? Map<String, dynamic>.from(rawUnitInfo as Map) : <String, dynamic>{};
                  final unitTitle = unitInfo['title']?.toString() ?? 'Unidad $unit';

                  final unitProgress = widget.progressList.firstWhere(
                    (p) => p.unit == unit,
                    orElse: () => LearningPathUnitProgress(level: widget.level, unit: unit, status: 'locked'),
                  );

                  return _ListeningUnitNode(
                    level: widget.level,
                    unit: unit,
                    unitTitle: unitTitle,
                    progress: unitProgress,
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _ListeningUnitNode extends StatelessWidget {
  final int level;
  final int unit;
  final String unitTitle;
  final LearningPathUnitProgress progress;

  const _ListeningUnitNode({
    required this.level,
    required this.unit,
    required this.unitTitle,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLocked = progress.status == 'locked';
    final bool isMastered = progress.status == 'mastered';
    final bool isInProgress = progress.status == 'in_progress';

    Color nodeColor = Colors.grey.shade800;
    IconData icon = Icons.lock;
    Color iconColor = Colors.white38;

    if (isMastered) {
      nodeColor = Colors.green.shade900.withValues(alpha: 0.4);
      icon = Icons.check_circle;
      iconColor = Colors.greenAccent;
    } else if (isInProgress) {
      nodeColor = const Color(0xFF0EA5E9).withValues(alpha: 0.2);
      icon = Icons.headphones;
      iconColor = const Color(0xFF38BDF8);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLocked
              ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Supera la unidad anterior para desbloquear esta lección.')),
                  );
                }
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IeltsListeningPracticeScreen(
                        level: level,
                        unit: unit,
                        unitTitle: unitTitle,
                      ),
                    ),
                  );
                },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: nodeColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isMastered
                    ? Colors.greenAccent.withValues(alpha: 0.6)
                    : (isInProgress ? const Color(0xFF38BDF8) : Colors.white10),
                width: isInProgress ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unidad $unit: $unitTitle',
                        style: TextStyle(
                          color: isLocked ? Colors.white38 : Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (progress.precisionScore != null)
                        Text(
                          'Precisión: ${progress.precisionScore!.toStringAsFixed(0)}%',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                        ),
                    ],
                  ),
                ),
                if (!isLocked) const Icon(Icons.chevron_right, color: Colors.white54),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
