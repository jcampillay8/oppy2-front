// lib/features/statistics/screens/statistics_screen.dart
import 'package:flutter/material.dart';
import 'package:oppy2_frontend/core/theme/app_theme.dart';
import 'package:oppy2_frontend/features/home/widgets/home_bottom_nav.dart';
import '../widgets/main_stats_cards.dart';
import '../widgets/learning_activity_chart.dart';
import '../widgets/ia_insight_card.dart';
import '../widgets/skills_breakdown.dart';
import '../widgets/recent_topics.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        title: const Text(
          'Estadísticas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const MainStatsCards(), // Días de racha y Nivel
                    const SizedBox(height: 24),
                    const LearningActivityChart(), // El gráfico de líneas
                    const SizedBox(height: 24),
                    const IAInsightCard(), // El banner azul con chispas
                    const SizedBox(height: 32),
                    const SkillsBreakdown(), // Vocabulario, Gramática, etc.
                    const SizedBox(height: 32),
                    const RecentTopics(), // Lista de temas al final
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            const HomeBottomNav(initialIndex: 3), // Índice 3 seleccionado
          ],
        ),
      ),
    );
  }
}