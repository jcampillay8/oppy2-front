// lib/features/roleplay_ia/models/avatar_model.dart
import 'dart:convert';

class AvatarModel {
  final int? id;
  final String guid;
  final String title;
  final int userId;
  final int? hostProfileId;
  final String name;
  final String? roleAvatar;
  final String? roleUsuario;
  final String? objective;
  final String? context;
  final String? characterTraits;
  final String? rules;
  final String languagePreference;
  final String selectedVoice;
  final bool isTtsEnabled;
  final bool isPublic;
  final int likesCount;
  final String? scenarioCategory;
  final bool isDeleted;
  final DateTime? createdAt;

  AvatarModel({
    this.id,
    required this.guid,
    required this.title,
    required this.userId,
    this.hostProfileId,
    required this.name,
    this.roleAvatar,
    this.roleUsuario,
    this.objective,
    this.context,
    this.characterTraits,
    this.rules,
    this.languagePreference = "en-US",
    this.selectedVoice = "us_female",
    this.isTtsEnabled = false,
    this.isPublic = false,
    this.likesCount = 0,
    this.scenarioCategory,
    this.isDeleted = false,
    this.createdAt,
  });

  AvatarModel copyWith({
    String? title,
    String? name,
    String? roleAvatar,
    String? roleUsuario, // 👈 CORREGIDO: Faltaba este parámetro
    String? objective,
    String? context,
    String? languagePreference,
    String? selectedVoice,
    bool? isTtsEnabled,
    bool? isPublic,
    int? likesCount,
    String? scenarioCategory,
  }) {
    return AvatarModel(
      id: id,
      guid: guid,
      title: title ?? this.title,
      userId: userId,
      hostProfileId: hostProfileId,
      name: name ?? this.name,
      roleAvatar: roleAvatar ?? this.roleAvatar,
      roleUsuario: roleUsuario ?? this.roleUsuario, // 👈 CORREGIDO: Ahora se asigna correctamente
      objective: objective ?? this.objective,
      context: context ?? this.context,
      characterTraits: characterTraits ?? this.characterTraits,
      rules: rules ?? this.rules,
      languagePreference: languagePreference ?? this.languagePreference,
      selectedVoice: selectedVoice ?? this.selectedVoice,
      isTtsEnabled: isTtsEnabled ?? this.isTtsEnabled,
      isPublic: isPublic ?? this.isPublic,
      likesCount: likesCount ?? this.likesCount,
      scenarioCategory: scenarioCategory ?? this.scenarioCategory,
      isDeleted: isDeleted,
      createdAt: createdAt,
    );
  }

  factory AvatarModel.fromJson(Map<String, dynamic> json) {
    return AvatarModel(
      id: json['id'],
      guid: json['guid'] ?? '',
      title: json['title'] ?? 'Escenario sin título',
      userId: json['userId'] ?? json['user_id'] ?? 0,
      hostProfileId: json['hostProfileId'] ?? json['host_profile_id'],
      name: json['name'] ?? '',
      roleAvatar: json['roleAvatar'] ?? json['role_avatar'],
      roleUsuario: json['roleUsuario'] ?? json['role_usuario'],
      objective: json['objective'],
      context: json['context'],
      characterTraits: json['characterTraits'] ?? json['character_traits'],
      rules: json['rules'],
      languagePreference: json['languagePreference'] ?? json['language_preference'] ?? 'en-US',
      selectedVoice: json['selectedVoice'] ?? json['selected_voice'] ?? 'us_female',
      isTtsEnabled: json['isTtsEnabled'] ?? json['is_tts_enabled'] ?? false,
      isPublic: json['isPublic'] ?? json['is_public'] ?? false,
      likesCount: json['likesCount'] ?? json['likes_count'] ?? 0,
      scenarioCategory: json['scenarioCategory'] ?? json['scenario_category'],
      isDeleted: json['isDeleted'] ?? json['is_deleted'] ?? false,
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? DateTime.parse(json['createdAt'] ?? json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'name': name,
      'role_avatar': roleAvatar,
      'role_usuario': roleUsuario,
      'objective': objective ?? "", // 👈 Si es null, enviamos un string vacío
      'context': context,
      'character_traits': characterTraits ?? "", // 👈 Evitamos más errores 422
      'rules': rules ?? "", // 👈 Evitamos más errores 422
      'language_preference': languagePreference,
      'selected_voice': selectedVoice,
      'is_tts_enabled': isTtsEnabled,
      'is_public': isPublic,
      'scenario_category': scenarioCategory,
    };
  }
}