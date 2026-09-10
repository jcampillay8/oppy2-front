import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/roleplay_ia/screens/tutor_selection_screen.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1E1E2C),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF2A2A3D),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.rocket_launch, color: Colors.white, size: 40),
                SizedBox(height: 10),
                Text(
                  'OppyChat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.school, color: Colors.greenAccent),
            title: const Text('Guía IELTS', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/ielts-path');
            },
          ),
          ListTile(
            leading: const Icon(Icons.headphones, color: Color(0xFF38BDF8)),
            title: const Text('Listening IELTS', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/ielts-listening-path');
            },
          ),
          ListTile(
            leading: const Icon(Icons.style, color: Colors.amber),
            title: const Text('Práctica de Vocabulario', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/vocabulary-practice');
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline, color: Colors.blueAccent),
            title: const Text('Chat Libre', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const TutorSelectionScreen()),
              );
            },
          ),
          const Divider(color: Colors.white12, height: 32),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Cerrar sesión', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
              }
            },
          ),
        ],
      ),
    );
  }
}
