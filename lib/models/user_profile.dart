class UserProfile {
  final int coins;
  final int xp;
  final int level;
  final int campaignLevel;
  
  // Inventario RPG
  final int visionCharges;
  final int timeFreezeCharges;
  final int divineTouchCharges;
  final String? xpBoostUntil; // ISO String
  final String activeAvatarBorder;
  final String activeTitle;

  final List<String> unlockedAchievements;
  final int dailyStreak;
  final String lastDailyPlayedDate;
  final List<String> completedDailyDates;
  final bool isRegistered;
  final String username;
  final String email;

  const UserProfile({
    this.coins = 100,
    this.xp = 0,
    this.level = 1,
    this.campaignLevel = 1,
    this.visionCharges = 3,
    this.timeFreezeCharges = 2,
    this.divineTouchCharges = 1,
    this.xpBoostUntil,
    this.activeAvatarBorder = 'none',
    this.activeTitle = '',
    this.unlockedAchievements = const [],
    this.dailyStreak = 0,
    this.lastDailyPlayedDate = '',
    this.completedDailyDates = const [],
    this.isRegistered = false,
    this.username = 'Invitado',
    this.email = '',
  });

  bool get hasActiveXpBoost {
    if (xpBoostUntil == null) return false;
    final boostDate = DateTime.tryParse(xpBoostUntil!);
    if (boostDate == null) return false;
    return boostDate.isAfter(DateTime.now());
  }

  /// Calcula la XP necesaria para subir al siguiente nivel.
  int get xpNeededForNextLevel => level * 1000;

  /// Porcentaje de progreso de XP en el nivel actual (0.0 a 1.0).
  double get progressPercentage {
    if (xpNeededForNextLevel == 0) return 0.0;
    return (xp / xpNeededForNextLevel).clamp(0.0, 1.0);
  }

  /// Título de Rango (Fase 2 GDD)
  String get rankTitle {
    if (level >= 100) return 'Oráculo';
    if (level >= 51) return 'Gran Maestro';
    if (level >= 31) return 'Arquitecto';
    if (level >= 16) return 'Analista';
    if (level >= 6) return 'Aprendiz';
    return 'Iniciado';
  }

  /// Emoji de Rango
  String get rankEmoji {
    if (level >= 100) return '👁️';
    if (level >= 51) return '👑';
    if (level >= 31) return '📐';
    if (level >= 16) return '🔬';
    if (level >= 6) return '⚙️';
    return '🌱';
  }

  UserProfile copyWith({
    int? coins,
    int? xp,
    int? level,
    int? campaignLevel,
    int? visionCharges,
    int? timeFreezeCharges,
    int? divineTouchCharges,
    String? xpBoostUntil,
    String? activeAvatarBorder,
    String? activeTitle,
    List<String>? unlockedAchievements,
    int? dailyStreak,
    String? lastDailyPlayedDate,
    List<String>? completedDailyDates,
    bool? isRegistered,
    String? username,
    String? email,
  }) {
    return UserProfile(
      coins: coins ?? this.coins,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      campaignLevel: campaignLevel ?? this.campaignLevel,
      visionCharges: visionCharges ?? this.visionCharges,
      timeFreezeCharges: timeFreezeCharges ?? this.timeFreezeCharges,
      divineTouchCharges: divineTouchCharges ?? this.divineTouchCharges,
      xpBoostUntil: xpBoostUntil ?? this.xpBoostUntil,
      activeAvatarBorder: activeAvatarBorder ?? this.activeAvatarBorder,
      activeTitle: activeTitle ?? this.activeTitle,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      lastDailyPlayedDate: lastDailyPlayedDate ?? this.lastDailyPlayedDate,
      completedDailyDates: completedDailyDates ?? this.completedDailyDates,
      isRegistered: isRegistered ?? this.isRegistered,
      username: username ?? this.username,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coins': coins,
      'xp': xp,
      'level': level,
      'campaignLevel': campaignLevel,
      'visionCharges': visionCharges,
      'timeFreezeCharges': timeFreezeCharges,
      'divineTouchCharges': divineTouchCharges,
      'xpBoostUntil': xpBoostUntil,
      'activeAvatarBorder': activeAvatarBorder,
      'activeTitle': activeTitle,
      'unlockedAchievements': unlockedAchievements,
      'dailyStreak': dailyStreak,
      'lastDailyPlayedDate': lastDailyPlayedDate,
      'completedDailyDates': completedDailyDates,
      'isRegistered': isRegistered,
      'username': username,
      'email': email,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      coins: json['coins'] as int? ?? 100,
      xp: json['xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      campaignLevel: json['campaignLevel'] as int? ?? 1,
      visionCharges: json['visionCharges'] as int? ?? 3,
      timeFreezeCharges: json['timeFreezeCharges'] as int? ?? 2,
      divineTouchCharges: json['divineTouchCharges'] as int? ?? 1,
      xpBoostUntil: json['xpBoostUntil'] as String?,
      activeAvatarBorder: json['activeAvatarBorder'] as String? ?? 'none',
      activeTitle: json['activeTitle'] as String? ?? '',
      unlockedAchievements: List<String>.from(json['unlockedAchievements'] as List<dynamic>? ?? []),
      dailyStreak: json['dailyStreak'] as int? ?? 0,
      lastDailyPlayedDate: json['lastDailyPlayedDate'] as String? ?? '',
      completedDailyDates: List<String>.from(json['completedDailyDates'] as List<dynamic>? ?? []),
      isRegistered: json['isRegistered'] as bool? ?? false,
      username: json['username'] as String? ?? 'Invitado',
      email: json['email'] as String? ?? '',
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
    Achievement(
      id: 'sabio_relampago',
      title: 'Sabio Relámpago',
      description: 'Resuelve un Sudoku en menos de 2.5 minutos.',
      rewardCoins: 75,
      rewardXp: 250,
      icon: '⚡',
    ),
    Achievement(
      id: 'el_intocable',
      title: 'El Intocable',
      description: 'Resuelve un Sudoku sin usar pistas ni cometer errores.',
      rewardCoins: 100,
      rewardXp: 350,
      icon: '🛡️',
    ),
    Achievement(
      id: 'gran_maestro',
      title: 'Maestría Absoluta',
      description: 'Completa un Sudoku en la dificultad Experto.',
      rewardCoins: 150,
      rewardXp: 500,
      icon: '👑',
    ),
    Achievement(
      id: 'coleccionista_temas',
      title: 'Esteta de la Lógica',
      description: 'Compra al menos 3 temas premium en la tienda.',
      rewardCoins: 50,
      rewardXp: 150,
      icon: '🎨',
    ),
    Achievement(
      id: 'campeon_torneo',
      title: 'Campeón de la Arena',
      description: 'Gana el primer lugar en cualquier torneo de la liga.',
      rewardCoins: 200,
      rewardXp: 600,
      icon: '🏆',
    ),
  ];
}
