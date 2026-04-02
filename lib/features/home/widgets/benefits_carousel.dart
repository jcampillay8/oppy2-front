// lib/features/home/widgets/benefits_carousel.dart
import 'package:flutter/material.dart';
import 'package:oppy2_frontend/core/theme/app_theme.dart';

class BenefitsCarousel extends StatelessWidget {
  const BenefitsCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Mis Beneficios', 
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {}, 
              child: const Text('Ver todo', style: TextStyle(color: AppColors.primaryBlue))
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.3), 
                blurRadius: 15, 
                offset: const Offset(0, 5)
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('NIVEL ACTUAL', 
                        style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          Icon(Icons.verified, color: AppColors.accentYellow, size: 20),
                          SizedBox(width: 6),
                          Text('Oro', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2), 
                      borderRadius: BorderRadius.circular(12)
                    ),
                    child: const Icon(Icons.redeem, color: Colors.white, size: 28),
                  )
                ],
              ),
              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('1,250 Puntos', style: TextStyle(color: Colors.white, fontSize: 14)),
                  Text('Próximo: 1,500', style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 8),
              const ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: LinearProgressIndicator(
                  value: 1250 / 1500,
                  minHeight: 8,
                  backgroundColor: Color(0xFF1E40AF),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentYellow),
                ),
              ),
              const SizedBox(height: 12),
              const Text('¡Estás cerca! Desbloquea un 20% en Starbucks.', 
                style: TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}