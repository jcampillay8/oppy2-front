// lib/features/statistics/widgets/learning_activity_chart.dart
import 'package:flutter/material.dart';
import 'package:oppy2_frontend/core/theme/app_theme.dart';

class LearningActivityChart extends StatelessWidget {
  const LearningActivityChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Actividad de aprendizaje',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tiempo total esta semana',
                    style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    '4.5h',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.trending_up, color: Colors.greenAccent, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '+15%',
                        style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // ESPACIO PARA EL GRÁFICO
          // Por ahora pondremos un placeholder con la forma, 
          // luego podemos implementar fl_chart aquí.
          SizedBox(
            height: 150,
            width: double.infinity,
            child: CustomPaint(
              painter: ChartPlaceholderPainter(),
            ),
          ),
          
          const SizedBox(height: 16),
          // Días de la semana
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM']
                .map((day) => Text(
                      day,
                      style: TextStyle(color: AppColors.textGrey, fontSize: 10, fontWeight: FontWeight.bold),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// Un pintor simple para dibujar la curva azul mientras configuras fl_chart
class ChartPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.2, size.width * 0.4, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.8, size.width * 0.8, size.height * 0.3);
    path.lineTo(size.width, size.height * 0.4);

    canvas.drawPath(path, paint);
    
    // Dibujar el punto brillante al final
    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.3), 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}