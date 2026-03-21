// lib/screens/confirm_email_screen.dart
import 'package:flutter/material.dart';
import 'package:oppychat/core/app_theme.dart';
import 'package:oppychat/services/auth_service.dart';

class ConfirmEmailScreen extends StatefulWidget {
  final String token;
  const ConfirmEmailScreen({super.key, required this.token});

  @override
  State<ConfirmEmailScreen> createState() => _ConfirmEmailScreenState();
}

class _ConfirmEmailScreenState extends State<ConfirmEmailScreen> {
  bool _isLoading = true;
  String _message = "Confirmando tu cuenta...";

  @override
  void initState() {
    super.initState();
    _confirmAccount();
  }

  Future<void> _confirmAccount() async {
    // Aquí llamas a tu backend
    final result = await AuthService().confirmEmail(widget.token);
    
    setState(() {
      _isLoading = false;
      _message = result ? "¡Cuenta activada con éxito!" : "El enlace ha expirado o es inválido.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const CircularProgressIndicator(color: AppColors.primaryBlue)
              else ...[
                const Icon(Icons.check_circle_outline, color: AppColors.primaryBlue, size: 80),
                const SizedBox(height: 24),
                Text(
                  _message,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text("Ir al Login", style: TextStyle(color: Colors.white)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}