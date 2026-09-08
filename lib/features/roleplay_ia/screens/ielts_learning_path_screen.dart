import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/ielts_path_provider.dart';
import '../models/learning_path_model.dart';
import 'ielts_guided_practice_screen.dart';

import '../widgets/ielts_activity_heatmap_sheet.dart';

class IeltsLearningPathScreen extends ConsumerStatefulWidget {
  const IeltsLearningPathScreen({super.key});

  @override
  ConsumerState<IeltsLearningPathScreen> createState() => _IeltsLearningPathScreenState();
}

class _IeltsLearningPathScreenState extends ConsumerState<IeltsLearningPathScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _levelKeysMap = {};
  bool _hasAutoScrolled = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToActiveLevel(int activeLevel) {
    final key = _levelKeysMap[activeLevel];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(ieltsPathProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Guía IELTS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                      color: AppColors.primaryBlue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Text("🔥", style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 4),
                        Text(
                          "${streak}d",
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
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
        data: (data) => _buildBody(context, data.progress, data.syllabus),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
        error: (error, _) => Center(
          child: Text('Error: $error', style: const TextStyle(color: Colors.redAccent)),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<LearningPathUnitProgress> progressList, Map<String, dynamic> syllabus) {
    final levelKeys = syllabus.keys.map((k) => int.tryParse(k.toString()) ?? 0).where((k) => k > 0).toList()..sort();

    // Find current active level & unit (the first in_progress or unmastered)
    LearningPathUnitProgress? activeProgress;
    for (var p in progressList) {
      if (p.status == 'in_progress') {
        activeProgress = p;
        break;
      }
    }

    final activeLevel = activeProgress?.level ?? 1;
    final activeUnit = activeProgress?.unit ?? 1;

    // Auto scroll once on initial load
    if (!_hasAutoScrolled) {
      _hasAutoScrolled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToActiveLevel(activeLevel);
      });
    }

    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(top: 16, bottom: 90, left: 16, right: 16),
          itemCount: levelKeys.length,
          itemBuilder: (context, index) {
            final level = levelKeys[index];
            _levelKeysMap.putIfAbsent(level, () => GlobalKey());

            final rawLevelData = syllabus[level.toString()];
            final levelData = rawLevelData != null ? Map<String, dynamic>.from(rawLevelData as Map) : <String, dynamic>{};
            final levelProgress = progressList.where((p) => p.level == level).toList();
            final rawUnits = levelData['units'];
            final unitsData = rawUnits != null ? Map<String, dynamic>.from(rawUnits as Map) : <String, dynamic>{};

            return KeyedSubtree(
              key: _levelKeysMap[level],
              child: _IeltsLevelSection(
                level: level,
                levelTitle: levelData['title']?.toString() ?? 'Módulo $level',
                cefr: levelData['cefr']?.toString() ?? '',
                unitsData: unitsData,
                progressList: levelProgress,
                isActiveLevel: level == activeLevel,
              ),
            );
          },
        ),

        // Floating "Continuar Lección" button
        Positioned(
          bottom: 20,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () => _scrollToActiveLevel(activeLevel),
            backgroundColor: AppColors.primaryBlue,
            elevation: 6,
            icon: const Icon(Icons.play_arrow, color: Colors.white),
            label: Text(
              "Continuar Módulo $activeLevel · U$activeUnit",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}

class _IeltsLevelSection extends StatefulWidget {
  final int level;
  final String levelTitle;
  final String cefr;
  final Map<String, dynamic> unitsData;
  final List<LearningPathUnitProgress> progressList;
  final bool isActiveLevel;

  const _IeltsLevelSection({
    required this.level,
    required this.levelTitle,
    required this.cefr,
    required this.unitsData,
    required this.progressList,
    required this.isActiveLevel,
  });

  @override
  State<_IeltsLevelSection> createState() => _IeltsLevelSectionState();
}

class _IeltsLevelSectionState extends State<_IeltsLevelSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    final unitKeys = widget.unitsData.keys.map((k) => int.tryParse(k.toString()) ?? 0).where((k) => k > 0).toList();
    final completedCount = widget.progressList.where((p) => p.status == 'mastered').length;
    final isFullyCompleted = completedCount == unitKeys.length && unitKeys.isNotEmpty;

    // Expand by default if active or in progress, collapse if completed or locked
    _isExpanded = widget.isActiveLevel || (!isFullyCompleted && completedCount > 0);
  }

  @override
  Widget build(BuildContext context) {
    final unitKeys = widget.unitsData.keys.map((k) => int.tryParse(k.toString()) ?? 0).where((k) => k > 0).toList()..sort();
    final totalUnits = unitKeys.length;
    final completedUnits = widget.progressList.where((p) => p.status == 'mastered').length;
    final isFullyCompleted = completedUnits == totalUnits && totalUnits > 0;
    final hasInProgress = widget.progressList.any((p) => p.status == 'in_progress');

    Color headerBg;
    Color borderCol;
    String statusBadgeText;
    Color badgeColor;

    if (isFullyCompleted) {
      headerBg = Colors.green.shade900.withValues(alpha: 0.25);
      borderCol = Colors.greenAccent.withValues(alpha: 0.5);
      statusBadgeText = "✅ Completado ($completedUnits de $totalUnits)";
      badgeColor = Colors.greenAccent;
    } else if (hasInProgress || widget.isActiveLevel) {
      headerBg = AppColors.primaryBlue.withValues(alpha: 0.25);
      borderCol = AppColors.primaryBlue;
      statusBadgeText = "⚡ En progreso ($completedUnits de $totalUnits)";
      badgeColor = AppColors.primaryBlue;
    } else {
      headerBg = const Color(0xFF2A2A3D);
      borderCol = Colors.white10;
      statusBadgeText = "🔒 Bloqueado ($completedUnits de $totalUnits)";
      badgeColor = Colors.white38;
    }

    final double progressRatio = totalUnits > 0 ? (completedUnits / totalUnits) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: headerBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol, width: widget.isActiveLevel ? 1.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row (Tap to expand/collapse)
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          'Módulo ${widget.level}',
                          style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (widget.cefr.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.cefr,
                            style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      const Spacer(),
                      Text(
                        statusBadgeText,
                        style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.white70,
                        size: 22,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.levelTitle,
                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // Linear progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressRatio,
                      minHeight: 4,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation<Color>(badgeColor),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Units List (Visible if expanded)
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

                  return _IeltsUnitNode(
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

class _IeltsUnitNode extends StatelessWidget {
  final int level;
  final int unit;
  final String unitTitle;
  final LearningPathUnitProgress progress;

  const _IeltsUnitNode({
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
      nodeColor = AppColors.primaryBlue.withValues(alpha: 0.2);
      icon = Icons.play_circle_fill;
      iconColor = AppColors.primaryBlue;
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
                      builder: (context) => IeltsGuidedPracticeScreen(
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
                    : (isInProgress ? AppColors.primaryBlue : Colors.white10),
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
                if (!isLocked)
                  const Icon(Icons.chevron_right, color: Colors.white54, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
