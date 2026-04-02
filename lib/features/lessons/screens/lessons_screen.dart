// lib/features/lessons/screens/lessons_screen.dart
import 'package:flutter/material.dart';
import 'package:oppy2_frontend/core/theme/app_theme.dart';
import 'package:oppy2_frontend/features/home/widgets/home_bottom_nav.dart';
import '../widgets/daily_challenge_card.dart';
import '../widgets/lessons_filter_bar.dart';
import '../widgets/continue_learning_card.dart';
import '../widgets/personalized_practice_grid.dart';
import '../widgets/suggested_lessons_list.dart';
import '../widgets/quick_doubts_banner.dart';

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});

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
          'Lecciones',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
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
                    const LessonsFilterBar(), // Selector de nivel y categoría
                    const SizedBox(height: 20),
                    const DailyChallengeCard(), // El banner morado de XP
                    const SizedBox(height: 32),
                    const Text(
                      'Continuar Aprendiendo',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const ContinueLearningCard(),
                    const SizedBox(height: 32),
                    const Text(
                      'Práctica Personalizada',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const PersonalizedPracticeGrid(),
                    const SizedBox(height: 32),
                    const Text(
                      'Sugeridos para ti',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const SuggestedLessonsList(),
                    const SizedBox(height: 32),
                    const QuickDoubtsBanner(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            const HomeBottomNav(initialIndex: 1), // Índice 1: Lecciones
          ],
        ),
      ),
    );
  }
}