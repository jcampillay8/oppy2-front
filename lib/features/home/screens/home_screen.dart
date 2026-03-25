// home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:oppy2_frontend/features/auth/providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos al provider para mostrar datos del usuario si queremos
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('OppyChat Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Simplemente cerramos sesión y la UI reaccionará sola
              context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            Text(
              '¡Bienvenido, ${auth.user?.username ?? "Usuario"}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text('Conectado a tu Backend en Docker'),
            const SizedBox(height: 10),
            Text('Status: ${auth.status.name}', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}