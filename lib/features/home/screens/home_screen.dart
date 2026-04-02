// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:oppy2_frontend/features/auth/providers/auth_provider.dart';
import 'package:oppy2_frontend/core/theme/app_theme.dart'; // Importante

import '../widgets/home_header.dart';
import '../widgets/benefits_carousel.dart';
import '../widgets/practice_grid.dart';
import '../widgets/friends_section.dart';
import '../widgets/featured_groups.dart';
import '../widgets/nearby_events.dart';
import '../widgets/home_bottom_nav.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final String username = auth.user?.username ?? "Usuario";

    return Scaffold(
      backgroundColor: AppColors.backgroundDark, // Usa AppColors
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(username: username),
              const SizedBox(height: 24),
              const BenefitsCarousel(),
              const SizedBox(height: 32),
              const PracticeGrid(),
              const SizedBox(height: 32),
              const FriendsSection(),
              const SizedBox(height: 32),
              const FeaturedGroups(),
              const SizedBox(height: 32),
              const NearbyEvents(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const HomeBottomNav(),
    );
  }
}