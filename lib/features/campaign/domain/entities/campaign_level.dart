/// Entidad de negocio pura e inmutable que representa un Nivel Estelar en el modo campaña.
/// Capa de Dominio (Domain Layer) - Pura y sin dependencias externas.
class CampaignLevel {
  final int levelNumber;
  final String difficulty;
  final String puzzleData;
  final String solutionData;
  final String? bossName;
  final int rewardCoins;
  final int rewardXp;
  final Map<String, dynamic> modifiers;

  const CampaignLevel({
    required this.levelNumber,
    required this.difficulty,
    required this.puzzleData,
    required this.solutionData,
    this.bossName,
    required this.rewardCoins,
    required this.rewardXp,
    required this.modifiers,
  });

  /// Determina si este nivel cósmico corresponde a una batalla contra un Jefe.
  bool isBoss() => bossName != null && bossName!.isNotEmpty;
}
