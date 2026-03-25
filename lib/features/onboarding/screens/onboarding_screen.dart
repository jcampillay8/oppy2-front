// lib/features/onboarding/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:oppy2_frontend/core/theme/app_theme.dart';
import 'package:oppy2_frontend/features/auth/services/auth_service.dart';

class OnboardingScreen extends StatefulWidget {
  final int initialStep;

  const OnboardingScreen({
    super.key, 
    this.initialStep = 1,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  final AuthService _authService = AuthService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  int _currentStep = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep - 1;
    _pageController = PageController(initialPage: _currentStep);
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    try {
      final status = await _authService.checkNavigationFlow();
      if (status != null) {
        setState(() {
          _usernameController.text = status['username'] ?? "";
          _occupationController.text = status['occupation'] ?? "";
          _bioController.text = status['bio'] ?? "";
          
          _currentStep = (status['current_step'] ?? 1) - 1;
          _isLoading = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) {
            _pageController.jumpToPage(_currentStep);
          }
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleNextStep() async {
    if (_isCurrentFieldEmpty()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, completa el campo")),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true); 
    
    try {
      final success = await _authService.updateOnboardingProfile(
        username: _usernameController.text.trim(),
        occupation: _occupationController.text.trim(),
        bio: _bioController.text.trim(),
      );

      if (success) {
        final status = await _authService.checkNavigationFlow();
        if (status != null) {
          int backendStep = (status['current_step'] ?? 1) - 1;
          
          setState(() => _isLoading = false);

          if (_pageController.hasClients) { 
            _pageController.animateToPage(
              backendStep,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic,
            );
          }
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error de conexión")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isCurrentFieldEmpty() {
    if (_currentStep == 0) return _usernameController.text.trim().isEmpty;
    if (_currentStep == 1) return _occupationController.text.trim().isEmpty;
    if (_currentStep == 2) return _bioController.text.trim().length < 10;
    return false;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _usernameController.dispose();
    _occupationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack( 
        children: [
          SafeArea(
            child: Column(
              children: [
                // Barra de progreso
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (_currentStep + 1) / 4,
                      backgroundColor: AppColors.outlineGrey,
                      color: AppColors.primaryBlue,
                      minHeight: 6,
                    ),
                  ),
                ),
                
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (int page) => setState(() => _currentStep = page),
                    children: [
                      _buildStep(
                        title: "Tu nombre de usuario",
                        subtitle: "¿Cómo te conocerá la comunidad?",
                        controller: _usernameController,
                        hint: "Ej: jgabriel",
                        icon: Icons.person_outline,
                        onPressed: _handleNextStep,
                      ),
                      _buildStep(
                        title: "¿A qué te dedicas?",
                        subtitle: "Para darte ejemplos relevantes.",
                        controller: _occupationController,
                        hint: "Ej: Ingeniero Civil",
                        icon: Icons.work_outline,
                        onPressed: _handleNextStep,
                      ),
                      _buildStep(
                        title: "Sobre ti",
                        subtitle: "Cuéntale a la IA tus intereses (min. 10 car.)",
                        controller: _bioController,
                        hint: "Me gusta la tecnología...",
                        icon: Icons.auto_awesome_outlined,
                        maxLines: 4,
                        buttonText: "Finalizar Perfil",
                        onPressed: _handleNextStep,
                      ),
                      _buildVista4(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: AppColors.backgroundDark.withOpacity(0.7),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryBlue),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required VoidCallback onPressed,
    String buttonText = "Continuar",
    int maxLines = 1,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 48, color: AppColors.primaryBlue),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(subtitle, style: const TextStyle(color: AppColors.textGrey, fontSize: 16)),
          const SizedBox(height: 40),
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textGrey),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.outlineGrey),
                borderRadius: BorderRadius.circular(16),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
          const SizedBox(height: 60),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(buttonText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVista4() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.stars_rounded, size: 100, color: AppColors.primaryBlue),
          const SizedBox(height: 40),
          const Text("¡Todo listo!", textAlign: TextAlign.center, 
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Text(
            "Tu perfil ha sido creado. Vamos a evaluar tu nivel de inglés.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textGrey, fontSize: 18),
          ),
          const SizedBox(height: 60),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/test-diagnostico'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.backgroundDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Empezar Test Diagnóstico", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}