import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';
import 'storage_provider.dart';

class ProfileNotifier extends StateNotifier<UserProfile> {
  final StorageService _storageService;

  // Canal/callback para alertar a la interfaz sobre eventos especiales de gamificación
  Function(String achievementTitle)? onAchievementUnlocked;
  Function(int newLevel, int rewardCoins)? onLevelUp;

  ProfileNotifier(this._storageService) : super(const UserProfile()) {
    _loadProfile();
  }

  void _loadProfile() {
    final coins = _storageService.getCoins();
    final xp = _storageService.getXp();
    final level = _storageService.getLevel();
    final achievements = _storageService.getUnlockedAchievements();
    final dailyStreak = _storageService.getDailyStreak();
    final lastDailyDate = _storageService.getLastDailyPlayedDate();

    state = UserProfile(
      coins: coins,
      xp: xp,
      level: level,
      unlockedAchievements: achievements,
      dailyStreak: dailyStreak,
      lastDailyPlayedDate: lastDailyDate,
    );
  }

  /// Añade monedas al perfil y las persiste.
  void addCoins(int amount) {
    final updatedCoins = state.coins + amount;
    state = state.copyWith(coins: updatedCoins);
    _storageService.saveCoins(updatedCoins);
  }

  /// Deduce monedas del perfil. Retorna true si tiene fondos, de lo contrario false.
  bool deductCoins(int amount) {
    if (state.coins < amount) return false;
    final updatedCoins = state.coins - amount;
    state = state.copyWith(coins: updatedCoins);
    _storageService.saveCoins(updatedCoins);
    return true;
  }

  /// Añade XP y maneja dinámicamente la subida de nivel.
  void addXp(int amount) {
    int currentXp = state.xp + amount;
    int currentLevel = state.level;
    bool leveledUp = false;

    // Progresión de nivel
    while (currentXp >= (currentLevel * 1000)) {
      currentXp -= (currentLevel * 1000);
      currentLevel++;
      leveledUp = true;
    }

    state = state.copyWith(xp: currentXp, level: currentLevel);
    _storageService.saveXp(currentXp);
    _storageService.saveLevel(currentLevel);

    if (leveledUp) {
      // Recompensa premium por subir de nivel
      final reward = currentLevel * 50; 
      addCoins(reward);
      onLevelUp?.call(currentLevel, reward);
    }
  }

  /// Desbloquea un logro si no está previamente desbloqueado.
  void unlockAchievement(String achievementId) {
    if (state.unlockedAchievements.contains(achievementId)) return;

    final achievement = Achievement.allAchievements.firstWhere(
      (a) => a.id == achievementId,
      orElse: () => throw Exception('Logro no encontrado'),
    );

    final updatedAchievements = [...state.unlockedAchievements, achievementId];
    state = state.copyWith(unlockedAchievements: updatedAchievements);
    _storageService.saveUnlockedAchievements(updatedAchievements);

    // Otorga las recompensas
    addCoins(achievement.rewardCoins);
    addXp(achievement.rewardXp);

    onAchievementUnlocked?.call(achievement.title);
  }

  /// Comprueba y gestiona las rachas diarias de juego.
  void checkDailyStreak() {
    final todayStr = DateTime.now().toIso8601String().substring(0, 10); // AAAA-MM-DD
    
    if (state.lastDailyPlayedDate == todayStr) {
      return; // Ya jugó hoy el sudoku diario
    }

    if (state.lastDailyPlayedDate.isEmpty) {
      // Primera vez
      _updateStreak(1, todayStr);
      return;
    }

    final lastDate = DateTime.parse(state.lastDailyPlayedDate);
    final today = DateTime.parse(todayStr);
    final difference = today.difference(lastDate).inDays;

    if (difference == 1) {
      // Racha consecutiva
      final newStreak = state.dailyStreak + 1;
      _updateStreak(newStreak, todayStr);

      if (newStreak >= 3) {
        unlockAchievement('constancia');
      }
    } else if (difference > 1) {
      // Se rompió la racha, reiniciamos a 1
      _updateStreak(1, todayStr);
    }
  }

  void _updateStreak(int streak, String dateStr) {
    state = state.copyWith(dailyStreak: streak, lastDailyPlayedDate: dateStr);
    _storageService.saveDailyStreak(streak);
    _storageService.saveLastDailyPlayedDate(dateStr);
  }
}

// Proveedor global del Perfil de Usuario
final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ProfileNotifier(storage);
});
