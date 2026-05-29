import '../../domain/entities/leaderboard_player.dart';

/// Modelo de datos específico para el parseo y serialización de JSON de la clasificación.
/// Extiende la entidad pura de dominio 'LeaderboardPlayer' agregando la infraestructura de JSON.
class LeaderboardPlayerModel extends LeaderboardPlayer {
  const LeaderboardPlayerModel({
    required super.userId,
    required super.username,
    required super.level,
    super.coins,
    super.xp,
    super.dailyStreak,
    super.difficulty,
    super.bestTime,
    super.gamesPlayed,
    super.gamesWon,
  });

  /// Crea un objeto [LeaderboardPlayerModel] a partir de un mapa JSON devuelto por el API.
  factory LeaderboardPlayerModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardPlayerModel(
      userId: json['user_id'] as int? ?? json['id'] as int? ?? 0,
      username: json['username'] as String? ?? 'Desconocido',
      level: json['level'] as int? ?? 1,
      coins: json['coins'] as int?,
      xp: json['xp'] as int?,
      dailyStreak: json['daily_streak'] as int?,
      difficulty: json['difficulty'] as String?,
      bestTime: json['best_time'] as int?,
      gamesPlayed: json['games_played'] as int?,
      gamesWon: json['games_won'] as int?,
    );
  }

  /// Convierte el objeto en un mapa JSON para almacenamiento o envíos de red.
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'level': level,
      if (coins != null) 'coins': coins,
      if (xp != null) 'xp': xp,
      if (dailyStreak != null) 'daily_streak': dailyStreak,
      if (difficulty != null) 'difficulty': difficulty,
      if (bestTime != null) 'best_time': bestTime,
      if (gamesPlayed != null) 'games_played': gamesPlayed,
      if (gamesWon != null) 'games_won': gamesWon,
    };
  }
}
