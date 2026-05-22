class UserProfile {
  final int coins;
  final int xp;
  final int level;
  final List<String> unlockedAchievements;
  final int dailyStreak;
  final String lastDailyPlayedDate;

  const UserProfile({
    this.coins = 100,
    this.xp = 0,
    this.level = 1,
    this.unlockedAchievements = const [],
    this.dailyStreak = 0,
    this.lastDailyPlayedDate = '',
  });

  /// Calcula la XP necesaria para subir al siguiente nivel.
  /// Fórmula simple de progresión premium: Nivel * 1000 XP.
  int get xpNeededForNextLevel => level * 1000;

  /// Porcentaje de progreso de XP en el nivel actual (0.0 a 1.0).
  double get progressPercentage {
    if (xpNeededForNextLevel == 0) return 0.0;
    return (xp / xpNeededForNextLevel).clamp(0.0, 1.0);
  }

  UserProfile copyWith({
    int? coins,
    int? xp,
    int? level,
    List<String>? unlockedAchievements,
    int? dailyStreak,
    String? lastDailyPlayedDate,
  }) {
    return UserProfile(
      coins: coins ?? this.coins,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      lastDailyPlayedDate: lastDailyPlayedDate ?? this.lastDailyPlayedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coins': coins,
      'xp': xp,
      'level': level,
      'unlockedAchievements': unlockedAchievements,
      'dailyStreak': dailyStreak,
      'lastDailyPlayedDate': lastDailyPlayedDate,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      coins: json['coins'] as int? ?? 100,
      xp: json['xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      unlockedAchievements: List<String>.from(json['unlockedAchievements'] as List<dynamic>? ?? []),
      dailyStreak: json['dailyStreak'] as int? ?? 0,
      lastDailyPlayedDate: json['lastDailyPlayedDate'] as String? ?? '',
    );
  }
}

/// Definición y metadatos de los logros de gamificación.
class Achievement {
  final String id;
  final String title;
  final String description;
  final int rewardCoins;
  final int rewardXp;
  final String icon;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardCoins,
    required this.rewardXp,
    required this.icon,
  });

  static const List<Achievement> allAchievements = [
    Achievement(
      id: 'primera_victoria',
      title: '¡Primer Paso!',
      description: 'Completa tu primer Sudoku con éxito.',
      rewardCoins: 30,
      rewardXp: 150,
      icon: '🏆',
    ),
    Achievement(
      id: 'velocista',
      title: 'Velocista Mental',
      description: 'Resuelve un Sudoku en menos de 4 minutos.',
      rewardCoins: 50,
      rewardXp: 300,
      icon: '⚡',
    ),
    Achievement(
      id: 'mente_acero',
      title: 'Mente de Acero',
      description: 'Resuelve un Sudoku en dificultad difícil o experto sin cometer errores.',
      rewardCoins: 100,
      rewardXp: 500,
      icon: '🧠',
    ),
    Achievement(
      id: 'resiliencia',
      title: 'Resiliencia Pura',
      description: 'Completa una partida tras cometer 2 errores.',
      rewardCoins: 30,
      rewardXp: 200,
      icon: '🛡️',
    ),
    Achievement(
      id: 'constancia',
      title: 'Hábito Diario',
      description: 'Consigue una racha diaria de juego de 3 días consecutivos.',
      rewardCoins: 75,
      rewardXp: 400,
      icon: '🔥',
    ),
  ];
}
