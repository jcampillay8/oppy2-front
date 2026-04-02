//a lib/features/home/widgets/home_bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:oppy2_frontend/core/theme/app_theme.dart';

class HomeBottomNav extends StatefulWidget {
  final int initialIndex; // Agregamos esto
  const HomeBottomNav({super.key, this.initialIndex = 0});

  @override
  State<HomeBottomNav> createState() => _HomeBottomNavState();
}

class _HomeBottomNavState extends State<HomeBottomNav> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.outlineGrey, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
      onTap: (index) {
          // 1. Si presionamos donde ya estamos, no hacemos nada
          if (index == widget.initialIndex) return;
          
          // 2. Lógica de navegación
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              // Navigator.pushReplacementNamed(context, '/lessons');
              break;
            case 2:
              // Navigator.pushReplacementNamed(context, '/rank');
              break;
            case 3:
              // Navegamos a la nueva pantalla de estadísticas
              Navigator.pushReplacementNamed(context, '/statistics');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
        backgroundColor: AppColors.backgroundDark,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textGrey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'Lecciones'),
          BottomNavigationBarItem(icon: Icon(Icons.stacked_line_chart), label: 'Rank'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Estadísticas'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }
}