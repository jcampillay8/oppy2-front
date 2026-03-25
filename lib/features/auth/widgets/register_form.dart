// lib/features/auth/widgets/register_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:oppy2_frontend/features/auth/providers/auth_provider.dart';
import 'package:oppy2_frontend/core/theme/app_theme.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  // Método centralizado para manejar el registro
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    // Guardamos la referencia al ScaffoldMessenger ANTES de cerrar el modal
    final messenger = ScaffoldMessenger.of(context);
    final authProvider = context.read<AuthProvider>();
    
    final success = await authProvider.register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _usernameController.text.trim(),
    );

    if (success && mounted) {
      // 1. Cerramos el modal primero
      Navigator.pop(context);

      // 2. Usamos la referencia guardada 'messenger' para mostrar el SnackBar.
      // Así ya no dependemos del context del widget que acabamos de destruir.
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.mark_email_read_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "📩 ¡Registro exitoso! Revisa tu email para activar tu cuenta.",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.blueAccent.shade700,
          duration: const Duration(seconds: 10),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(20),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              // Ya no llamamos a nada con context aquí, el OK solo cierra el SnackBar
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usamos watch para reaccionar al estado de carga (authenticating)
    final authStatus = context.watch<AuthProvider>().status;
    final isAuthenticating = authStatus == AuthStatus.authenticating;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 30, 
        left: 25, 
        right: 25, 
        top: 25,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Crea tu cuenta', 
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)
            ),
            const SizedBox(height: 8),
            const Text(
              'Únete a la comunidad de OppyChat',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 25),
            
            _buildTextField(
              controller: _usernameController,
              label: 'Nombre de usuario',
              icon: Icons.person_outline,
              validator: (v) => v!.isEmpty ? 'Ingresa un nombre de usuario' : null,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _emailController,
              label: 'Correo electrónico',
              icon: Icons.email_outlined,
              validator: (v) => !v!.contains('@') ? 'Ingresa un email válido' : null,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _passwordController,
              label: 'Contraseña',
              icon: Icons.lock_outline,
              isPassword: true,
              validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
            ),
            
            const SizedBox(height: 35),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isAuthenticating ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: isAuthenticating
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Registrarse', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para mantener el estilo de los campos
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20),
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: AppColors.outlineGrey.withOpacity(0.1),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.outlineGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}