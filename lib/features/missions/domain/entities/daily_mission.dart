/// Entidad pura representativa de una Misión Diaria.
/// Capa de Dominio (Domain Layer) - Pura y sin dependencias externas o de Flutter.
class DailyMission {
  final int id;
  final String title;
  final String description;
  final int requirementValue;
  final int currentProgress;
  final int rewardCoins;
  final int rewardXp;
  final bool isCompleted;

  const DailyMission({
    required this.id,
    required this.title,
    required this.description,
    required this.requirementValue,
    required this.currentProgress,
    required this.rewardCoins,
    required this.rewardXp,
    required this.isCompleted,
  });

  /// Crea una copia de la entidad con propiedades modificadas.
  DailyMission copyWith({
    int? id,
    String? title,
    String? description,
    int? requirementValue,
    int? currentProgress,
    int? rewardCoins,
    int? rewardXp,
    bool? isCompleted,
  }) {
    return DailyMission(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      requirementValue: requirementValue ?? this.requirementValue,
      currentProgress: currentProgress ?? this.currentProgress,
      rewardCoins: rewardCoins ?? this.rewardCoins,
      rewardXp: rewardXp ?? this.rewardXp,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
