import '../../domain/entities/daily_mission.dart';

/// Modelo de datos de red que extiende la entidad de negocio.
/// Capa de Datos (Data Layer) - Maneja la serialización JSON.
class DailyMissionModel extends DailyMission {
  const DailyMissionModel({
    required super.id,
    required super.title,
    required super.description,
    required super.requirementValue,
    required super.currentProgress,
    required super.rewardCoins,
    required super.rewardXp,
    required super.isCompleted,
  });

  /// Deserializa un objeto JSON a un modelo tipado seguro.
  factory DailyMissionModel.fromJson(Map<String, dynamic> json) {
    return DailyMissionModel(
      id: json['mission_id'] ?? json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      requirementValue: json['requirement_value'] ?? 0,
      currentProgress: json['current_progress'] ?? 0,
      rewardCoins: json['reward_coins'] ?? 0,
      rewardXp: json['reward_xp'] ?? 0,
      isCompleted: json['is_completed'] ?? false,
    );
  }

  /// Serializa el modelo a un mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'mission_id': id,
      'title': title,
      'description': description,
      'requirement_value': requirementValue,
      'current_progress': currentProgress,
      'reward_coins': rewardCoins,
      'reward_xp': rewardXp,
      'is_completed': isCompleted,
    };
  }
}
