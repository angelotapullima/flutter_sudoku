import '../../domain/entities/campaign_level.dart';

/// Modelo de datos que hereda de la entidad de negocio y maneja la serialización JSON.
/// Capa de Datos (Data Layer) - Convierte datos en bruto a objetos fuertemente tipados.
class CampaignLevelModel extends CampaignLevel {
  const CampaignLevelModel({
    required super.levelNumber,
    required super.difficulty,
    required super.puzzleData,
    required super.solutionData,
    super.bossName,
    required super.rewardCoins,
    required super.rewardXp,
    required super.modifiers,
  });

  /// Deserializa un objeto JSON a un modelo tipado seguro protegiendo nulos.
  factory CampaignLevelModel.fromJson(Map<String, dynamic> json) {
    return CampaignLevelModel(
      levelNumber: json['level_number'] ?? json['levelNumber'] ?? 0,
      difficulty: json['difficulty'] ?? 'Fácil',
      puzzleData: json['puzzle_data'] ?? json['puzzleData'] ?? '',
      solutionData: json['solution_data'] ?? json['solutionData'] ?? '',
      bossName: json['boss_name'] ?? json['bossName'],
      rewardCoins: json['reward_coins'] ?? json['rewardCoins'] ?? 50,
      rewardXp: json['reward_xp'] ?? json['rewardXp'] ?? 200,
      modifiers: json['modifiers'] ?? {},
    );
  }

  /// Serializa el modelo a un mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'level_number': levelNumber,
      'difficulty': difficulty,
      'puzzle_data': puzzleData,
      'solution_data': solutionData,
      'boss_name': bossName,
      'reward_coins': rewardCoins,
      'reward_xp': rewardXp,
      'modifiers': modifiers,
    };
  }
}
