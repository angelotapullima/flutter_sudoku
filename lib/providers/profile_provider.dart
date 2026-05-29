import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import 'storage_provider.dart';
import '../utils/enums.dart';
import '../features/auth/presentation/providers/auth_notifier.dart';

class ProfileNotifier extends StateNotifier<UserProfile> {
  final StorageService _storageService;
  final Ref ref;

  // Canal/callback para alertar a la interfaz sobre eventos especiales de gamificación
  Function(String achievementTitle)? onAchievementUnlocked;
  Function(int newLevel, int rewardCoins)? onLevelUp;

  ProfileNotifier(this._storageService, this.ref) : super(const UserProfile()) {
    _loadProfile();
    // Intentar obtener el perfil más reciente de la nube inmediatamente
    if (state.isRegistered) {
      refreshProfileFromServer();
    }
  }

  void _loadProfile() {
    final coins = _storageService.getCoins();
    final xp = _storageService.getXp();
    final level = _storageService.getLevel();
    final achievements = _storageService.getUnlockedAchievements();
    final dailyStreak = _storageService.getDailyStreak();
    final lastDailyDate = _storageService.getLastDailyPlayedDate();
    final completedDates = _storageService.getCompletedDailyDates();
    final isRegistered = _storageService.getIsRegistered();
    final username = _storageService.getUsername();
    final email = _storageService.getEmail();

    // Cargar campos RPG (Fase 4)
    final campaignLevel = _storageService.getCampaignLevel();
    final visionCharges = _storageService.getVisionCharges();
    final timeFreezeCharges = _storageService.getTimeFreezeCharges();
    final divineTouchCharges = _storageService.getDivineTouchCharges();
    final xpBoostUntil = _storageService.getXpBoostUntil();
    final activeAvatarBorder = _storageService.getActiveAvatarBorder();
    final activeTitle = _storageService.getActiveTitle();

    state = UserProfile(
      coins: coins,
      xp: xp,
      level: level,
      campaignLevel: campaignLevel,
      visionCharges: visionCharges,
      timeFreezeCharges: timeFreezeCharges,
      divineTouchCharges: divineTouchCharges,
      xpBoostUntil: xpBoostUntil,
      activeAvatarBorder: activeAvatarBorder,
      activeTitle: activeTitle,
      unlockedAchievements: achievements,
      dailyStreak: dailyStreak,
      lastDailyPlayedDate: lastDailyDate,
      completedDailyDates: completedDates,
      isRegistered: isRegistered,
      username: username,
      email: email,
    );
  }

  /// Construye un mapa con el progreso local completo para sincronizar con la nube
  Map<String, dynamic> getLocalProgressMap() {
    final difficulties = GameDifficultyExtension.playableLabels;
    final recordsList = difficulties.map((diff) {
      return {
        'difficulty': diff,
        'bestTime': _storageService.getBestTime(diff),
        'gamesPlayed': _storageService.getGamesPlayed(diff),
        'gamesWon': _storageService.getGamesWon(diff),
      };
    }).toList();

    return {
      'coins': state.coins,
      'xp': state.xp,
      'level': state.level,
      'campaignLevel': state.campaignLevel,
      'visionCharges': state.visionCharges,
      'timeFreezeCharges': state.timeFreezeCharges,
      'divineTouchCharges': state.divineTouchCharges,
      'xpBoostUntil': state.xpBoostUntil,
      'activeAvatarBorder': state.activeAvatarBorder,
      'activeTitle': state.activeTitle,
      'dailyStreak': state.dailyStreak,
      'lastDailyPlayedDate': state.lastDailyPlayedDate,
      'unlockedAchievements': state.unlockedAchievements,
      'purchasedThemes': _storageService.getPurchasedThemes(),
      'completedDailyDates': state.completedDailyDates,
      'records': recordsList,
    };
  }

  /// Guarda una respuesta del perfil del servidor en SharedPreferences locales
  Future<void> _saveServerProfileLocally(
      Map<String, dynamic> serverProfile) async {
    final coins = serverProfile['coins'] as int? ?? 100;
    final xp = serverProfile['xp'] as int? ?? 0;
    final level = serverProfile['level'] as int? ?? 1;
    final campaignLevel = serverProfile['campaignLevel'] as int? ?? 1;
    final dailyStreak = serverProfile['dailyStreak'] as int? ?? 0;
    final lastDailyDate = serverProfile['lastDailyPlayedDate'] as String? ?? '';

    // RPG Fields (Fase 4)
    final visionCharges = serverProfile['visionCharges'] as int? ?? 3;
    final timeFreezeCharges = serverProfile['timeFreezeCharges'] as int? ?? 2;
    final divineTouchCharges = serverProfile['divineTouchCharges'] as int? ?? 1;
    final xpBoostUntil = serverProfile['xpBoostUntil'] as String?;
    final activeAvatarBorder =
        serverProfile['activeAvatarBorder'] as String? ?? 'none';
    final activeTitle = serverProfile['activeTitle'] as String? ?? '';

    final achievements =
        List<String>.from(serverProfile['unlockedAchievements'] ?? []);
    final themes =
        List<String>.from(serverProfile['purchasedThemes'] ?? ['azul']);
    final dailyDates =
        List<String>.from(serverProfile['completedDailyDates'] ?? []);

    // Persistir en almacenamiento local
    await _storageService.saveCoins(coins);
    await _storageService.saveXp(xp);
    await _storageService.saveLevel(level);
    await _storageService.saveCampaignLevel(campaignLevel);
    await _storageService.saveDailyStreak(dailyStreak);
    await _storageService.saveLastDailyPlayedDate(lastDailyDate);
    await _storageService.saveUnlockedAchievements(achievements);
    await _storageService.savePurchasedThemes(themes);
    await _storageService.saveCompletedDailyDates(dailyDates);

    // Persistir RPG
    await _storageService.saveVisionCharges(visionCharges);
    await _storageService.saveTimeFreezeCharges(timeFreezeCharges);
    await _storageService.saveDivineTouchCharges(divineTouchCharges);
    await _storageService.saveXpBoostUntil(xpBoostUntil);
    await _storageService.saveActiveAvatarBorder(activeAvatarBorder);
    await _storageService.saveActiveTitle(activeTitle);

    // Sincronizar récords
    if (serverProfile['records'] != null) {
      final recordsList = serverProfile['records'] as List<dynamic>;
      for (final rec in recordsList) {
        final diff = rec['difficulty'] as String;
        final bestTime = rec['bestTime'] as int? ?? 0;
        final played = rec['gamesPlayed'] as int? ?? 0;
        final won = rec['gamesWon'] as int? ?? 0;

        await _storageService.saveBestTime(diff, bestTime);
        await _storageService.saveGamesPlayed(diff, played);
        await _storageService.saveGamesWon(diff, won);
      }
    }

    // Actualizar datos de registro
    final username = serverProfile['username'] as String? ?? state.username;
    final email = serverProfile['email'] as String? ?? state.email;
    await _storageService.saveRegistrationDetails(
      isRegistered: true,
      username: username,
      email: email,
    );

    // Actualizar el estado del provider
    state = state.copyWith(
      coins: coins,
      xp: xp,
      level: level,
      campaignLevel: campaignLevel,
      visionCharges: visionCharges,
      timeFreezeCharges: timeFreezeCharges,
      divineTouchCharges: divineTouchCharges,
      xpBoostUntil: xpBoostUntil,
      activeAvatarBorder: activeAvatarBorder,
      activeTitle: activeTitle,
      unlockedAchievements: achievements,
      dailyStreak: dailyStreak,
      lastDailyPlayedDate: lastDailyDate,
      completedDailyDates: dailyDates,
      isRegistered: true,
      username: username,
      email: email,
    );
  }

  /// Descarga el perfil del servidor inmediatamente después de iniciar sesión o registrarse,
  /// forzando la sincronización de sesión e inicialización del perfil stelar.
  Future<bool> refreshProfileFromServerAfterAuth() async {
    final result = await ApiService.getUserProfile();

    if (result['success']) {
      final serverProfile = result['data'];
      await _saveServerProfileLocally(serverProfile);
      return true;
    }
    return false;
  }

  /// SINCRONIZAR PROGRESO CON EL SERVIDOR
  Future<void> syncWithServer() async {
    if (!state.isRegistered) return;

    final localProgress = getLocalProgressMap();
    final result = await ApiService.syncProfile(localProgress: localProgress);

    if (result['success']) {
      final serverProfile = result['data'];
      await _saveServerProfileLocally(serverProfile);
      print('✅ Progreso sincronizado exitosamente con la nube.');
    } else {
      print('⚠️ Error al sincronizar con el backend: ${result['message']}');
      if (result['status'] == 401) {
        await logout();
      }
    }
  }

  /// OBTENER PERFIL ACTUAL DE LA NUBE
  Future<void> refreshProfileFromServer() async {
    if (!state.isRegistered) return;

    final result = await ApiService.getUserProfile();

    if (result['success']) {
      final serverProfile = result['data'];
      await _saveServerProfileLocally(serverProfile);
    } else {
      if (result['status'] == 401) {
        await logout();
      } else {
        syncWithServer();
      }
    }
  }

  /// CERRAR SESIÓN
  Future<void> logout() async {
    await ref.read(authStateProvider.notifier).logout();
    await _storageService.saveRegistrationDetails(
      isRegistered: false,
      username: 'Invitado',
      email: '',
    );
    state = state.copyWith(
      isRegistered: false,
      username: 'Invitado',
      email: '',
    );
  }

  /// Actualiza el perfil de forma granular y lo persiste localmente.
  Future<void> updateProfile(UserProfile updatedProfile) async {
    state = updatedProfile;

    await _storageService.saveCoins(state.coins);
    await _storageService.saveXp(state.xp);
    await _storageService.saveLevel(state.level);
    await _storageService.saveCampaignLevel(state.campaignLevel);
    await _storageService.saveVisionCharges(state.visionCharges);
    await _storageService.saveTimeFreezeCharges(state.timeFreezeCharges);
    await _storageService.saveDivineTouchCharges(state.divineTouchCharges);
    await _storageService.saveXpBoostUntil(state.xpBoostUntil);
    await _storageService.saveActiveAvatarBorder(state.activeAvatarBorder);
    await _storageService.saveActiveTitle(state.activeTitle);

    syncWithServer();
  }

  /// Añade monedas al perfil y las persiste.
  void addCoins(int amount) {
    final updatedCoins = state.coins + amount;
    state = state.copyWith(coins: updatedCoins);
    _storageService.saveCoins(updatedCoins);
    syncWithServer();
  }

  /// Deduce monedas del perfil.
  bool deductCoins(int amount) {
    if (state.coins < amount) return false;
    final updatedCoins = state.coins - amount;
    state = state.copyWith(coins: updatedCoins);
    _storageService.saveCoins(updatedCoins);
    syncWithServer();
    return true;
  }

  /// Añade XP y maneja subida de nivel.
  void addXp(int amount) {
    final int finalAmount = state.hasActiveXpBoost ? amount * 2 : amount;

    int currentXp = state.xp + finalAmount;
    int currentLevel = state.level;
    bool leveledUp = false;

    while (currentXp >= (currentLevel * 1000)) {
      currentXp -= (currentLevel * 1000);
      currentLevel++;
      leveledUp = true;
    }

    state = state.copyWith(xp: currentXp, level: currentLevel);
    _storageService.saveXp(currentXp);
    _storageService.saveLevel(currentLevel);

    if (leveledUp) {
      final reward = currentLevel * 50;
      addCoins(reward);
      onLevelUp?.call(currentLevel, reward);
    } else {
      syncWithServer();
    }
  }

  /// Desbloquea un logro.
  void unlockAchievement(String achievementId) {
    if (state.unlockedAchievements.contains(achievementId)) return;

    final achievement = Achievement.allAchievements.firstWhere(
      (a) => a.id == achievementId,
      orElse: () => throw Exception('Logro no encontrado'),
    );

    final updatedAchievements = [...state.unlockedAchievements, achievementId];
    state = state.copyWith(unlockedAchievements: updatedAchievements);
    _storageService.saveUnlockedAchievements(updatedAchievements);

    addCoins(achievement.rewardCoins);
    addXp(achievement.rewardXp);

    onAchievementUnlocked?.call(achievement.title);
  }

  /// Completa el Reto Diario
  void completeDailyChallenge(String dateStr) {
    if (state.completedDailyDates.contains(dateStr)) return;

    final updatedCompletedDates = [...state.completedDailyDates, dateStr];
    _storageService.saveCompletedDailyDates(updatedCompletedDates);

    final lastPlayStr = state.lastDailyPlayedDate;
    int newStreak = state.dailyStreak;

    if (lastPlayStr.isEmpty) {
      newStreak = 1;
    } else {
      try {
        final lastDate = DateTime.parse(lastPlayStr);
        final currentDate = DateTime.parse(dateStr);
        final difference = currentDate.difference(lastDate).inDays;

        if (difference == 1) {
          newStreak = state.dailyStreak + 1;
        } else if (difference > 1) {
          newStreak = 1;
        }
      } catch (_) {
        newStreak = 1;
      }
    }

    state = state.copyWith(
      completedDailyDates: updatedCompletedDates,
      dailyStreak: newStreak,
      lastDailyPlayedDate: dateStr,
    );

    _storageService.saveDailyStreak(newStreak);
    _storageService.saveLastDailyPlayedDate(dateStr);

    addCoins(50);
    addXp(200);

    if (newStreak >= 3) {
      unlockAchievement('constancia');
    }
  }

  /// Añade XP y Monedas simultáneamente (Usado en victoria de campaña)
  void addXpAndCoins(int xp, int coins) {
    addXp(xp);
    addCoins(coins);
  }

  /// Comprueba y gestiona las rachas de juego clásicas.
  void checkDailyStreak() {
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);

    if (state.lastDailyPlayedDate == todayStr) return;

    if (state.lastDailyPlayedDate.isEmpty) {
      _updateStreak(1, todayStr);
      return;
    }

    try {
      final lastDate = DateTime.parse(state.lastDailyPlayedDate);
      final today = DateTime.parse(todayStr);
      final difference = today.difference(lastDate).inDays;

      if (difference == 1) {
        final newStreak = state.dailyStreak + 1;
        _updateStreak(newStreak, todayStr);
        if (newStreak >= 3) unlockAchievement('constancia');
      } else if (difference > 1) {
        _updateStreak(1, todayStr);
      }
    } catch (_) {
      _updateStreak(1, todayStr);
    }
  }

  void _updateStreak(int streak, String dateStr) {
    state = state.copyWith(dailyStreak: streak, lastDailyPlayedDate: dateStr);
    _storageService.saveDailyStreak(streak);
    _storageService.saveLastDailyPlayedDate(dateStr);
    syncWithServer();
  }

  /// Actualiza el nivel de campaña (viaje) desbloqueado y lo sincroniza.
  void updateCampaignLevel(int newCampaignLevel) {
    if (newCampaignLevel <= state.campaignLevel) return;
    state = state.copyWith(campaignLevel: newCampaignLevel);
    _storageService.saveCampaignLevel(newCampaignLevel);
    syncWithServer();
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, UserProfile>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ProfileNotifier(storage, ref);
});
