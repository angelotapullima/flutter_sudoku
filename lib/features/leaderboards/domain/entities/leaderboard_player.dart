/// Entidad pura de dominio que representa a un jugador en la tabla de clasificaciones.
/// Está completamente libre de cualquier dependencia externa, anotaciones JSON o base de datos.
class LeaderboardPlayer {
  final int userId;
  final String username;
  final int level;
  final int? coins;
  final int? xp;
  final int? dailyStreak;

  // Específicos para clasificación de velocidad
  final String? difficulty;
  final int? bestTime;
  final int? gamesPlayed;
  final int? gamesWon;

  const LeaderboardPlayer({
    required this.userId,
    required this.username,
    required this.level,
    this.coins,
    this.xp,
    this.dailyStreak,
    this.difficulty,
    this.bestTime,
    this.gamesPlayed,
    this.gamesWon,
  });
}
