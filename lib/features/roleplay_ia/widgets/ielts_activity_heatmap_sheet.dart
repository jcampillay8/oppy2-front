import 'package:flutter/material.dart';

class IeltsActivityHeatmapSheet extends StatelessWidget {
  final Map<String, dynamic> stats;

  const IeltsActivityHeatmapSheet({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final currentStreak = stats['current_streak'] ?? 0;
    final totalResponses = stats['total_responses'] ?? 0;
    final dailyAverage = stats['daily_average'] ?? 0.0;
    final activityList = (stats['activity_data'] as List? ?? []);

    // Convert activity list into Map<"YYYY-MM-DD", int>
    final Map<String, int> activityMap = {};
    for (var item in activityList) {
      if (item is Map) {
        final d = item['date']?.toString();
        final c = int.tryParse(item['count']?.toString() ?? '0') ?? 0;
        if (d != null) {
          activityMap[d] = c;
        }
      }
    }

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E2C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Text("🔥", style: TextStyle(fontSize: 24)),
                  SizedBox(width: 8),
                  Text(
                    "Constancia en Guía IELTS",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stat Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: "Racha Actual",
                  value: "$currentStreak días",
                  icon: "🔥",
                  color: Colors.orangeAccent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  title: "Total Respuestas",
                  value: "$totalResponses",
                  icon: "📝",
                  color: Colors.greenAccent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  title: "Promedio Diario",
                  value: "$dailyAverage / día",
                  icon: "🎯",
                  color: Colors.lightBlueAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Heatmap section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Mapa de Actividad Diaria",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              _buildLegend(),
            ],
          ),
          const SizedBox(height: 12),

          // Flutter Native Heatmap Grid
          _buildHeatmapGrid(context, activityMap),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        const Text("Menos ", style: TextStyle(color: Colors.white38, fontSize: 10)),
        _buildLegendBox(const Color(0xFF2A2A3D)),
        const SizedBox(width: 3),
        _buildLegendBox(Colors.greenAccent.withValues(alpha: 0.35)),
        const SizedBox(width: 3),
        _buildLegendBox(Colors.greenAccent.withValues(alpha: 0.70)),
        const SizedBox(width: 3),
        _buildLegendBox(Colors.greenAccent),
        const Text(" Más", style: TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }

  Widget _buildLegendBox(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeatmapGrid(BuildContext context, Map<String, int> activityMap) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Find the Monday of the current week (weekday: 1=Mon, ..., 7=Sun)
    final currentMonday = today.subtract(Duration(days: today.weekday - 1));
    
    final int totalWeeks = 16;
    final firstMonday = currentMonday.subtract(Duration(days: (totalWeeks - 1) * 7));

    final weekDayLabels = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"];
    final monthNames = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true, // Scroll to end (current week) by default
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Header Row
          Row(
            children: [
              // Offset for Y-axis weekday labels
              const SizedBox(width: 34),
              Row(
                children: List.generate(totalWeeks, (weekIndex) {
                  final weekMonday = firstMonday.add(Duration(days: weekIndex * 7));
                  final isFirstWeek = weekIndex == 0;
                  final prevWeekMonday = weekIndex > 0 ? firstMonday.add(Duration(days: (weekIndex - 1) * 7)) : null;
                  final isNewMonth = isFirstWeek || (prevWeekMonday != null && weekMonday.month != prevWeekMonday.month);

                  return Container(
                    width: 30, // 26px tile + 4px margin
                    alignment: Alignment.centerLeft,
                    child: isNewMonth
                        ? Text(
                            monthNames[weekMonday.month - 1],
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const SizedBox.shrink(),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Main Heatmap Grid (Labels + Week Columns)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Y-axis day labels (Lun to Dom)
              Column(
                children: List.generate(7, (dayIndex) {
                  return Container(
                    height: 26,
                    alignment: Alignment.centerRight,
                    margin: const EdgeInsets.only(right: 8, bottom: 4),
                    child: Text(
                      weekDayLabels[dayIndex],
                      style: const TextStyle(color: Colors.white38, fontSize: 10),
                    ),
                  );
                }),
              ),

              // Grid of weeks
              Row(
                children: List.generate(totalWeeks, (weekIndex) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Column(
                      children: List.generate(7, (dayOfWeekIndex) {
                        final cellDate = firstMonday.add(Duration(days: (weekIndex * 7) + dayOfWeekIndex));
                        final isFuture = cellDate.isAfter(today);

                        final dateStr =
                            "${cellDate.year}-${cellDate.month.toString().padLeft(2, '0')}-${cellDate.day.toString().padLeft(2, '0')}";
                        final count = isFuture ? 0 : (activityMap[dateStr] ?? 0);

                        Color cellColor;
                        if (isFuture) {
                          cellColor = const Color(0xFF181824); // Subtle background for future days of current week
                        } else if (count == 0) {
                          cellColor = const Color(0xFF2A2A3D);
                        } else if (count <= 4) {
                          cellColor = Colors.greenAccent.withValues(alpha: 0.35);
                        } else if (count <= 9) {
                          cellColor = Colors.greenAccent.withValues(alpha: 0.70);
                        } else {
                          cellColor = Colors.greenAccent;
                        }

                        return GestureDetector(
                          onTap: () {
                            if (!isFuture) {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: const Color(0xFF2A2A3D),
                                  content: Text(
                                    "$dateStr (${weekDayLabels[dayOfWeekIndex]}): ${count == 0 ? 'Sin actividad' : '$count ejercicios resueltos'}",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: 26,
                            height: 26,
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: cellColor,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: count > 0 ? Colors.greenAccent.withValues(alpha: 0.6) : Colors.transparent,
                                width: 0.5,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: count > 0
                                ? Text(
                                    "$count",
                                    style: TextStyle(
                                      color: count > 9 ? Colors.black : Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
