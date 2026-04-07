// lib/features/roleplay_ia/screens/avatar_editor_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../models/avatar_model.dart';
import '../providers/avatar_provider.dart';

class AvatarEditorScreen extends ConsumerStatefulWidget {
  final AvatarModel? avatar; // Si es null, estamos creando uno nuevo

  const AvatarEditorScreen({super.key, this.avatar});

  @override
  ConsumerState<AvatarEditorScreen> createState() => _AvatarEditorScreenState();
}

class _AvatarEditorScreenState extends ConsumerState<AvatarEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para los campos principales
  late TextEditingController _titleController;
  late TextEditingController _nameController;
  late TextEditingController _contextController;
  late TextEditingController _objectiveController;
  late TextEditingController _traitsController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.avatar?.title ?? '');
    _nameController = TextEditingController(text: widget.avatar?.name ?? '');
    _contextController = TextEditingController(text: widget.avatar?.context ?? '');
    _objectiveController = TextEditingController(text: widget.avatar?.objective ?? '');
    _traitsController = TextEditingController(text: widget.avatar?.characterTraits ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _nameController.dispose();
    _contextController.dispose();
    _objectiveController.dispose();
    _traitsController.dispose();
    super.dispose();
  }

  void _saveAvatar() async {
    if (_formKey.currentState!.validate()) {
      final newAvatar = (widget.avatar ?? AvatarModel(
        guid: '', // El backend generará esto
        userId: 0, // Se asocia en el backend
        name: '',
        title: '',
      )).copyWith(
        title: _titleController.text,
        name: _nameController.text,
        context: _contextController.text,
        objective: _objectiveController.text,
      );

      // Lógica para llamar al provider y guardar
      // ref.read(avatarProvider.notifier).addAvatar(newAvatar);
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escenario guardado correctamente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.avatar == null ? 'Nuevo Escenario' : 'Editar Avatar'),
        actions: [
          TextButton(
            onPressed: _saveAvatar,
            child: const Text('GUARDAR', style: TextStyle(color: AppColors.accentBlue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionTitle("Información Básica"),
            _buildTextField(
              controller: _titleController,
              label: "Título del Escenario",
              hint: "Ej: Check-in en el Hotel",
              validator: (v) => v!.isEmpty ? 'El título es requerido' : null,
            ),
            _buildTextField(
              controller: _nameController,
              label: "Nombre del Personaje",
              hint: "Ej: Sarah Pearson",
            ),
            const SizedBox(height: 20),
            
            _buildSectionTitle("Configuración de la IA"),
            _buildTextField(
              controller: _contextController,
              label: "Contexto (System Prompt)",
              hint: "Describe dónde están y qué está pasando...",
              maxLines: 4,
            ),
            _buildTextField(
              controller: _objectiveController,
              label: "Objetivo del Estudiante",
              hint: "¿Qué debe lograr el usuario en esta charla?",
              maxLines: 3,
            ),
            _buildTextField(
              controller: _traitsController,
              label: "Rasgos de Personalidad",
              hint: "Ej: Amigable, estricta, impaciente...",
              maxLines: 2,
            ),
            
            const SizedBox(height: 30),
            // Switch para visibilidad
            SwitchListTile(
              title: const Text("Hacer público (para todos los usuarios)", style: TextStyle(color: Colors.white, fontSize: 14)),
              value: widget.avatar?.isPublic ?? false,
              onChanged: (val) {},
              activeColor: AppColors.accentBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(color: AppColors.accentBlue, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.textGrey.withOpacity(0.5), fontSize: 13),
          filled: true,
          fillColor: AppColors.cardGrey,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accentBlue)),
        ),
      ),
    );
  }
}