// lib/features/home/widgets/nearby_events.dart
import 'package:flutter/material.dart';
import 'package:oppy2_frontend/core/theme/app_theme.dart';

class NearbyEvents extends StatelessWidget {
  const NearbyEvents({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Eventos cercanos', 
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardGrey, 
            borderRadius: BorderRadius.circular(20)
          ),
          clipBehavior: Clip.hardEdge, 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 140, 
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFDE68A), Color(0xFFF59E0B)], 
                    begin: Alignment.topLeft, 
                    end: Alignment.bottomRight
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 12, left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6), 
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: const Text('HOY, 19:00', 
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Intercambio de Idiomas en La Roma', 
                      style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.location_on_outlined, color: AppColors.textGrey, size: 16),
                        SizedBox(width: 4),
                        Text('Café Pendulo, Ciudad de México', 
                          style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        SizedBox(
                          width: 45, 
                          height: 24,
                          child: Stack(
                            children: [
                              const CircleAvatar(radius: 12, backgroundColor: AppColors.primaryBlue),
                              Positioned(
                                left: 14,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: AppColors.cardGrey,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const CircleAvatar(radius: 10, backgroundColor: AppColors.successGreen),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('+12', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                            foregroundColor: AppColors.primaryBlue,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('ASISTIR'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}