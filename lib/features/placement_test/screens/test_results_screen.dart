// lib/features/placement_test/screens/test_results_screen.dart
import 'package:flutter/material.dart';

class TestResultsScreen extends StatelessWidget {
  const TestResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. EXTRAER LA DATA REAL DEL BACKEND
    // Si por alguna razón la data viene nula, usamos valores por defecto para evitar que la app explote
    final Map<String, dynamic>? data = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String globalLevel = data?['global_level'] ?? "A1";
    final String levelName = data?['level_name'] ?? "Principiante";
    final String aiAnalysis = data?['ai_analysis'] ?? "No hay análisis disponible.";
    final String suggestedPlan = data?['suggested_plan'] ?? "Plan Básico";
    
    // Scores vienen como 0-100 desde el backend, dividimos por 100 para el LinearProgressIndicator (0.0 a 1.0)
    final Map<String, dynamic> scores = data?['scores'] ?? {
      'writing': 0.0,
      'reading': 0.0,
      'listening': 0.0,
      'speaking': 0.0,
    };

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        title: const Text("Resultados", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildLevelCircle(globalLevel, levelName),
            const SizedBox(height: 30),
            
            // Pasamos los scores reales al desglose
            _buildSkillsBreakdown(scores),
            const SizedBox(height: 20),

            // Pasamos el texto de la IA real
            _buildAIAnalysisCard(aiAnalysis, suggestedPlan),
            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Próximos Pasos", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 15),
            _buildNextSteps(data?['next_steps']),
            
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                ),
                onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                child: const Text("Comenzar mi Plan →", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCircle(String level, String name) {
    return Column(
      children: [
        Container(
          width: 150, height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue, width: 8),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(level, style: const TextStyle(color: Colors.blue, fontSize: 48, fontWeight: FontWeight.bold)),
              const Text("NIVEL", style: TextStyle(color: Colors.white54, fontSize: 14)),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Text("¡$name!", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSkillsBreakdown(Map<String, dynamic> scores) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Desglose de Habilidades", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          // Convertimos el score 0-100 a decimal 0.0-1.0
          _skillBar("Writing", (scores['writing'] ?? 0) / 100, Colors.purple),
          _skillBar("Reading", (scores['reading'] ?? 0) / 100, Colors.green),
          _skillBar("Listening", (scores['listening'] ?? 0) / 100, Colors.blue),
          _skillBar("Speaking", (scores['speaking'] ?? 0) / 100, Colors.orange),
        ],
      ),
    );
  }

  Widget _skillBar(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white)),
              Text("${(value * 100).toInt()}%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: value, 
            backgroundColor: Colors.white10, 
            valueColor: AlwaysStoppedAnimation<Color>(color), 
            minHeight: 8
          ),
        ],
      ),
    );
  }

  Widget _buildAIAnalysisCard(String analysis, String plan) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.withOpacity(0.2), Colors.blue.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.blue),
              SizedBox(width: 10),
              Text("Análisis de Oppy", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            analysis, // Data dinámica de Gemini
            style: const TextStyle(color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 15),
          Align(
            alignment: Alignment.centerRight,
            child: Text("Plan sugerido: $plan", style: const TextStyle(color: Colors.white54, fontSize: 12)),
          )
        ],
      ),
    );
  }

Widget _buildNextSteps(List<dynamic>? steps) {
    // Si el backend envía pasos personalizados, los mapeamos aquí
    if (steps == null || steps.isEmpty) {
      return const Center(
        child: Text(
          "No hay pasos sugeridos todavía.", 
          style: TextStyle(color: Colors.white24)
        ),
      );
    }

    return Row(
      children: steps.map((step) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _stepCard(
              _getIconData(step['icon']), // Mapeo dinámico del string a IconData
              step['title'] ?? 'Tarea', 
              step['desc'] ?? 'Práctica sugerida', 
              Colors.blueAccent
            ),
          ),
        );
      }).toList(),
    );
  }

  // Función auxiliar para convertir el string del backend en un Icono de Flutter
  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'mic':
        return Icons.mic;
      case 'edit':
        return Icons.edit;
      case 'auto_stories':
        return Icons.auto_stories; // Icono ideal para Reading
      case 'chat':
        return Icons.chat_bubble_outline;
      default:
        return Icons.lightbulb_outline; // Icono por defecto
    }
  }

  Widget _stepCard(IconData icon, String title, String desc, Color color) {
    return Container(
      // Altura mínima para que todas las tarjetas se vean iguales si el texto varía
      constraints: const BoxConstraints(minHeight: 120),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), 
        borderRadius: BorderRadius.circular(15)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 10),
          Text(
            title, 
            style: const TextStyle(
              color: Colors.white, 
              fontWeight: FontWeight.bold, 
              fontSize: 13
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            desc, 
            style: const TextStyle(color: Colors.white54, fontSize: 11),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}