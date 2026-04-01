// lib/features/placement_test/screens/speaking_test_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oppy2_frontend/core/network/api_client.dart';
import '../services/placement_test_service.dart';


class SpeakingTestScreen extends StatefulWidget {
  const SpeakingTestScreen({super.key});

  @override
  State<SpeakingTestScreen> createState() => _SpeakingTestScreenState();
}

class _SpeakingTestScreenState extends State<SpeakingTestScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _audioPath;
  Timer? _timer;
  int _secondsElapsed = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  // --- LOGICA DE GRABACIÓN ---
  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final String path = '${directory.path}/speaking_test.m4a';
        const config = RecordConfig(); 

        await _audioRecorder.start(config, path: path);

        setState(() {
          _isRecording = true;
          _secondsElapsed = 0;
          _audioPath = null; // Limpiar previo
        });

        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() => _secondsElapsed++);
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> _stopRecording() async {
    final path = await _audioRecorder.stop();
    _timer?.cancel();
    setState(() {
      _isRecording = false;
      _audioPath = path;
    });
  }

  // --- NAVEGACIÓN Y ENVÍO ---
  
  void _showAnalyzingView() {
    // Esta es la Imagen 2 (El Robot Oppy)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 20),
              const Text("¡Test finalizado!", 
                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              const Text("¡Gracias por completar tu test!", 
                style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 50),
              // Simulación del Robot Oppy (Imagen 2)
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 200, width: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white10, width: 2),
                    ),
                  ),
                  const Icon(Icons.smart_toy, size: 100, color: Colors.blue), // Aquí va tu Asset de Robot
                ],
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(color: Colors.blue),
              const SizedBox(height: 20),
              const Text("Espera mientras Oppy analiza tus resultados", 
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

Future<void> _submitSpeakingTest() async {
  if (_audioPath == null) return;

  try {
    final apiClient = ApiClient(const FlutterSecureStorage());
    final service = PlacementTestService(apiClient);
    
    // 1. Enviamos el audio (esto gatilla la evaluación en el backend)
    await service.evaluateSpeaking(_audioPath!);

    if (mounted) {
      // 2. EN LUGAR DE IR A RESULTS, VAMOS A LA PANTALLA DE ANÁLISIS
      // Esta pantalla es la que llamará a /final-status por nosotros
      Navigator.pushReplacementNamed(context, '/analyzing-test');
    }
  } catch (e) {
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al analizar: $e")),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text("SECCIÓN 4 DE 4", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.5)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const LinearProgressIndicator(value: 1.0, backgroundColor: Colors.white12, valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)),
          const SizedBox(height: 20),
          _buildHeaderTag(),
          const Spacer(),
          _buildQuestionSection(),
          const Spacer(),
          _buildTimerDisplay(),
          const SizedBox(height: 30),
          _buildWaveform(),
          const Spacer(),
          _buildControls(),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildHeaderTag() {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.mic, color: Colors.blue, size: 16),
            SizedBox(width: 8),
            Text("Speaking", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
    );
  }

  Widget _buildQuestionSection() {
    return Column(
      children: [
        const CircleAvatar(radius: 35, backgroundColor: Color(0xFF1E293B), child: Icon(Icons.lightbulb, color: Colors.blue, size: 30)),
        const SizedBox(height: 25),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Text("Why is it important for you to learn English?", // Sincronizado con Backend
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 15),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text("Intenta hablar durante al menos 30 segundos para una mejor evaluación.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 15)),
        ),
      ],
    );
  }

  Widget _buildTimerDisplay() {
    String min = (_secondsElapsed ~/ 60).toString().padLeft(2, '0');
    String seg = (_secondsElapsed % 60).toString().padLeft(2, '0');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _timeBox(min, "MIN"),
        const Text(" : ", style: TextStyle(color: Colors.white, fontSize: 30)),
        _timeBox(seg, "SEG", isHighlighted: true),
      ],
    );
  }

  Widget _timeBox(String val, String label, {bool isHighlighted = false}) {
    return Column(children: [
      Container(
        width: 70, height: 70,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(15)),
        child: Text(val, style: TextStyle(color: isHighlighted ? Colors.blue : Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
      ),
      const SizedBox(height: 8),
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _buildWaveform() {
    return SizedBox(
      height: 40,
      child: _isRecording 
        ? Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(15, (i) => 
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 3, height: 10 + (i % 4 * 10.0),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.8), borderRadius: BorderRadius.circular(10)),
            )))
        : const Text("Listo para grabar", style: TextStyle(color: Colors.white24)),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        IconButton(icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 30), 
          onPressed: _audioPath != null ? () => setState(() => _audioPath = null) : null),
        GestureDetector(
          onTap: _isRecording ? _stopRecording : _startRecording,
          child: Container(
            height: 75, width: 75,
            decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle, boxShadow: [
              BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 15, spreadRadius: 5)
            ]),
            child: Icon(_isRecording ? Icons.stop : Icons.mic, color: Colors.white, size: 35),
          ),
        ),
        IconButton(icon: const Icon(Icons.play_circle_outline, color: Colors.white38, size: 30), onPressed: null),
      ]),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: SizedBox(
        width: double.infinity, height: 55,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            disabledBackgroundColor: Colors.white10,
          ),
          onPressed: _audioPath == null ? null : _submitSpeakingTest,
          child: const Text("Finalizar Test →", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}