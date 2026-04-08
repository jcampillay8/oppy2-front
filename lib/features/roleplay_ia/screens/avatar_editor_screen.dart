// lib/features/roleplay_ia/screens/avatar_editor_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../models/avatar_model.dart';
import '../providers/avatar_provider.dart';
import '../providers/category_provider.dart'; 

class AvatarEditorScreen extends ConsumerStatefulWidget {
  final AvatarModel? avatar;

  const AvatarEditorScreen({super.key, this.avatar});

  @override
  ConsumerState<AvatarEditorScreen> createState() => _AvatarEditorScreenState();
}

class _AvatarEditorScreenState extends ConsumerState<AvatarEditorScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  late TextEditingController _titleController;
  late TextEditingController _nameController;
  late TextEditingController _roleAvatarController;
  late TextEditingController _roleUsuarioController;
  late TextEditingController _contextController;
  
  // Estado local
  List<String> _selectedTags = [];
  bool _isPublic = false;
  bool _isSaving = false; // Prevención de doble click

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.avatar?.title ?? '');
    _nameController = TextEditingController(text: widget.avatar?.name ?? '');
    _roleAvatarController = TextEditingController(text: widget.avatar?.roleAvatar ?? '');
    _roleUsuarioController = TextEditingController(text: widget.avatar?.roleUsuario ?? '');
    _contextController = TextEditingController(text: widget.avatar?.context ?? '');
    
    _isPublic = widget.avatar?.isPublic ?? false;

    if (widget.avatar?.scenarioCategory != null && widget.avatar!.scenarioCategory!.isNotEmpty) {
      _selectedTags = widget.avatar!.scenarioCategory!
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _nameController.dispose();
    _roleAvatarController.dispose();
    _roleUsuarioController.dispose();
    _contextController.dispose();
    super.dispose();
  }

  Future<void> _saveAvatar() async {
    if (_formKey.currentState!.validate() && !_isSaving) {
      setState(() => _isSaving = true);

      try {
        final String tagsAsString = _selectedTags.join(', ');

        final updatedAvatar = (widget.avatar ?? AvatarModel(
          guid: '', 
          userId: 0,
          name: '',
          title: '',
          likesCount: 0,
        )).copyWith(
          title: _titleController.text.trim(),
          name: _nameController.text.trim(),
          roleAvatar: _roleAvatarController.text.trim(),
          roleUsuario: _roleUsuarioController.text.trim(),
          context: _contextController.text.trim(),
          isPublic: _isPublic,
          scenarioCategory: tagsAsString,
        );

        final success = await ref.read(avatarProvider.notifier).upsertAvatar(updatedAvatar);
        
        if (mounted) {
          if (success) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.avatar == null 
                  ? 'Escenario creado exitosamente' 
                  : 'Cambios guardados con éxito'),
                backgroundColor: AppColors.accentBlue,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al conectar con el servidor'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.avatar == null ? 'Nuevo Escenario' : 'Editar Escenario',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: _isSaving ? null : _saveAvatar,
              child: _isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentBlue))
                : const Text('GUARDAR', style: TextStyle(color: AppColors.accentBlue, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            _buildSectionTitle("Identidad del Escenario"),
            _buildTextField(
              controller: _titleController,
              label: "Título",
              hint: "Ej: Negociación de inversión Serie A",
              validator: (v) => v!.isEmpty ? 'El título es requerido' : null,
            ),
            
            const SizedBox(height: 16),
            _buildSectionTitle("Definición de Roles"),
            _buildTextField(
              controller: _nameController,
              label: "Nombre de la IA",
              hint: "Ej: Mr. Sterling",
              prefixIcon: Icons.smart_toy_outlined,
              validator: (v) => v!.isEmpty ? 'El nombre de la IA es requerido' : null,
            ),
            _buildTextField(
              controller: _roleAvatarController,
              label: "Rol de la IA",
              hint: "Ej: Un inversor escéptico y directo",
              prefixIcon: Icons.assignment_ind_outlined,
              validator: (v) => v!.isEmpty ? 'Define el comportamiento de la IA' : null,
            ),
            _buildTextField(
              controller: _roleUsuarioController,
              label: "Tu Rol (Usuario)",
              hint: "Ej: Fundador de una startup buscando fondos",
              prefixIcon: Icons.person_outline_rounded,
              validator: (v) => v!.isEmpty ? 'Define tu papel en la historia' : null,
            ),
            
            const SizedBox(height: 24),
            _buildSectionTitle("Clasificación"),
            categoriesAsync.when(
              data: (allCategories) => _buildTagSelector(allCategories),
              loading: () => const LinearProgressIndicator(color: AppColors.accentBlue),
              error: (err, _) => Text("Error de categorías: $err", 
                style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle("Instrucciones del Sistema"),
            _buildTextField(
              controller: _contextController,
              label: "Contexto Detallado (Prompt)",
              hint: "Describe el lugar, la actitud de la IA y reglas específicas...",
              maxLines: 6,
              validator: (v) => v!.isEmpty ? 'El contexto es vital para el LLM' : null,
            ),
            
            const SizedBox(height: 30),
            _buildPublicSwitch(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTagSelector(List<String> allowedTags) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
            return allowedTags.where((tag) =>
                tag.toLowerCase().contains(textEditingValue.text.toLowerCase()) &&
                !_selectedTags.contains(tag));
          },
          onSelected: (String selection) {
            if (_selectedTags.length < 3) {
              setState(() => _selectedTags.add(selection));
            }
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return _buildTextField(
              controller: controller,
              focusNode: focusNode,
              label: "Buscar categorías (Máx. 3)",
              prefixIcon: Icons.search_rounded,
            );
          },
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _selectedTags.map((tag) => Chip(
            label: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 12)),
            backgroundColor: AppColors.accentBlue.withOpacity(0.1),
            deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.accentBlue),
            onDeleted: () => setState(() => _selectedTags.remove(tag)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: AppColors.accentBlue, width: 0.5),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildPublicSwitch() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _isPublic ? AppColors.accentBlue.withOpacity(0.5) : Colors.transparent),
      ),
      child: SwitchListTile(
        title: const Text("Hacer público", 
          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: const Text("Disponible para la comunidad", 
          style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
        value: _isPublic,
        onChanged: (val) => setState(() => _isPublic = val),
        activeColor: AppColors.accentBlue,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.accentBlue, 
          fontSize: 10, 
          fontWeight: FontWeight.bold, 
          letterSpacing: 1.2
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String label,
    String? hint,
    IconData? prefixIcon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.accentBlue, size: 20) : null,
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textGrey, fontSize: 13),
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.textGrey.withOpacity(0.3), fontSize: 13),
          filled: true,
          fillColor: AppColors.cardGrey,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), 
            borderSide: const BorderSide(color: AppColors.accentBlue, width: 1.5)
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1)
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}