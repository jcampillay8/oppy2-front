// lib/features/placement_test/screens/analyzing_results_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Asegúrate de tener Provider o tu DI
import '../services/placement_test_service.dart';

class AnalyzingResultsScreen extends StatefulWidget {
  const AnalyzingResultsScreen({super.key});

  @override
  State<AnalyzingResultsScreen> createState() => _AnalyzingResultsScreenState();
}

class _AnalyzingResultsScreenState extends State<AnalyzingResultsScreen> {
  @override
  void initState() {
    super.initState();
    _fetchFinalResults();
  }

  Future<void> _fetchFinalResults() async {
    try {
      // 1. Obtenemos el servicio ya inyectado en el main.dart
      final service = context.read<PlacementTestService>();
      
      // 2. Esperamos un poco para que se vea el robot Oppy (opcional)
      await Future.delayed(const Duration(seconds: 2));
      
      // 3. Llamada al endpoint consolidado
      final result = await service.getFinalStatus(); 
      
      if (mounted) {
        // 4. PASAR LOS ARGUMENTOS: Aquí es donde el A1 se convierte en B1
        Navigator.pushReplacementNamed(
          context, 
          '/test-results',
          arguments: result, // <-- Esto es lo que lee TestResultsScreen
        );
      }
    } catch (e) {
      debugPrint("Error obteniendo resultados finales: $e");
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text("¡Test finalizado!", 
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 60),
            Image.asset('assets/images/oppy_robot.png', height: 220), 
            const SizedBox(height: 60),
            const CircularProgressIndicator(color: Colors.blue),
            const SizedBox(height: 20),
            const Text("Oppy está analizando tu nivel...", 
              style: TextStyle(color: Colors.blue, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}