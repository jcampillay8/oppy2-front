// lib/features/ranking/screens/ranking_screen.dart
import 'package:flutter/material.dart';
import 'package:oppy2_frontend/core/theme/app_theme.dart';
import 'package:oppy2_frontend/features/home/widgets/home_bottom_nav.dart';
import '../widgets/ranking_filter_tabs.dart';
import '../widgets/top_three_podium.dart';
import '../widgets/ranking_list_item.dart';
import '../widgets/current_user_rank_bar.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Clasificación',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: false, // Alineado a la izquierda según la imagen
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: RankingFilterTabs(), // Global, Regional, Amigos
            ),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        const TopThreePodium(), // Los 3 ganadores
                        const SizedBox(height: 32),
                        // Cabecera de la lista
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('PUESTO', style: TextStyle(color: AppColors.textGrey, fontSize: 12, fontWeight: FontWeight.bold)),
                            Text('PUNTOS', style: TextStyle(color: AppColors.textGrey, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Lista de usuarios (Puestos 4+)
                        const RankingListItem(rank: 4, name: 'Emily R.', country: 'USA', points: '1,950 XP'),
                        const RankingListItem(rank: 5, name: 'David K.', country: 'UK', points: '1,850 XP'),
                        const RankingListItem(rank: 6, name: 'Lucas P.', country: 'BR', points: '1,720 XP'),
                        const RankingListItem(rank: 7, name: 'Anna S.', country: 'DE', points: '1,680 XP'),
                        const RankingListItem(rank: 8, name: 'Mark D.', country: 'CA', points: '1,500 XP'),
                        const SizedBox(height: 100), // Espacio para que la barra flotante no tape el último
                      ],
                    ),
                  ),
                  // Barra flotante del usuario actual
                  const Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: CurrentUserRankBar(),
                  ),
                ],
              ),
            ),
            const HomeBottomNav(initialIndex: 2), // Índice del Rank
          ],
        ),
      ),
    );
  }
}