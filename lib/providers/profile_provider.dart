import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import 'storage_provider.dart';

class ProfileNotifier extends StateNotifier<UserProfile> {
  final StorageService _storageService;

  // Canal/callback para alertar a la interfaz sobre eventos especiales de gamificación
  Function(String achievementTitle)? onAchievementUnlocked;
  Function(int newLevel, int rewardCoins)? onLevelUp;

  ProfileNotifier(this._storageService) : super(const UserProfile()) {
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

    state = UserProfile(
      coins: coins,
      xp: xp,
      level: level,
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
    const difficulties = ['Fácil', 'Medio', 'Difícil', 'Experto'];
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
      'dailyStreak': state.dailyStreak,
      'lastDailyPlayedDate': state.lastDailyPlayedDate,
      'unlockedAchievements': state.unlockedAchievements,
      'purchasedThemes': _storageService.getPurchasedThemes(),
      'completedDailyDates': state.completedDailyDates,
      'records': recordsList,
    };
  }

  /// Guarda una respuesta del perfil del servidor en SharedPreferences locales
  Future<void> _saveServerProfileLocally(Map<String, dynamic> serverProfile) async {
    final coins = serverProfile['coins'] as int? ?? 100;
    final xp = serverProfile['xp'] as int? ?? 0;
    final level = serverProfile['level'] as int? ?? 1;
    final dailyStreak = serverProfile['dailyStreak'] as int? ?? 0;
    final lastDailyDate = serverProfile['lastDailyPlayedDate'] as String? ?? '';
    
    final achievements = List<String>.from(serverProfile['unlockedAchievements'] ?? []);
    final themes = List<String>.from(serverProfile['purchasedThemes'] ?? ['azul']);
    final dailyDates = List<String>.from(serverProfile['completedDailyDates'] ?? []);

    // Persistir en almacenamiento local
    await _storageService.saveCoins(coins);
    await _storageService.saveXp(xp);
    await _storageService.saveLevel(level);
    await _storageService.saveDailyStreak(dailyStreak);
    await _storageService.saveLastDailyPlayedDate(lastDailyDate);
    await _storageService.saveUnlockedAchievements(achievements);
    await _storageService.savePurchasedThemes(themes);
    await _storageService.saveCompletedDailyDates(dailyDates);

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
    } else {
      print('⚠️ El servidor no envió información de récords.');
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
      unlockedAchievements: achievements,
      dailyStreak: dailyStreak,
      lastDailyPlayedDate: lastDailyDate,
      completedDailyDates: dailyDates,
      isRegistered: true,
      username: username,
      email: email,
    );
  }

  /// REGISTRAR CUENTA EN EL SERVIDOR
  /// Convierte el perfil local actual y lo envía para que no se pierdan datos de invitado.
  Future<Map<String, dynamic>> registerUserInCloud({
    required String username,
    required String email,
    required String password,
  }) async {
    final localProgress = getLocalProgressMap();

    final result = await ApiService.register(
      username: username,
      email: email,
      password: password,
      localProgress: localProgress,
    );

    if (result['success']) {
      final serverProfile = result['data']['profile'];
      await _saveServerProfileLocally(serverProfile);
      return {'success': true};
    } else {
      return {'success': false, 'message': result['message']};
    }
  }

  /// INICIAR SESIÓN EN EL SERVIDOR
  /// Descarga el progreso unificado de la nube y sobreescribe localmente
  Future<Map<String, dynamic>> loginUserInCloud({
    required String email,
    required String password,
  }) async {
    final result = await ApiService.login(
      email: email,
      password: password,
    );

    if (result['success']) {
      final serverProfile = result['data']['profile'];
      await _saveServerProfileLocally(serverProfile);
      return {'success': true};
    } else {
      return {'success': false, 'message': result['message']};
    }
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
      // SI EL ERROR ES 401, CERRAR SESIÓN AUTOMÁTICAMENTE (Token inválido o DB reset)
      if (result['status'] == 401) {
        print('🚪 Detectada sesión inválida. Cerrando sesión local...');
        await logout();
      }
    }
  }

  /// OBTENER PERFIL ACTUAL DE LA NUBE (Prioridad servidor)
  Future<void> refreshProfileFromServer() async {
    if (!state.isRegistered) return;

    final result = await ApiService.getUserProfile();

    if (result['success']) {
      final serverProfile = result['data'];
      await _saveServerProfileLocally(serverProfile);
      print('✅ Perfil actualizado desde la nube.');
    } else {
      print('⚠️ No se pudo obtener perfil de la nube: ${result['message']}');
      
      if (result['status'] == 401) {
        await logout();
      } else {
        // Si falla por otra cosa, intentamos una sincronización bidireccional
        syncWithServer();
      }
    }
  }

  /// CERRAR SESIÓN (Limpiar credenciales y volver a estado local de invitado)
  Future<void> logout() async {
    await ApiService.clearToken();
    
    // Cambiar estado a invitado en SharedPreferences locales
    await _storageService.saveRegistrationDetails(
      isRegistered: false,
      username: 'Invitado',
      email: '',
    );

    // Reiniciar valores locales de progreso a por defecto (o conservar los locales del dispositivo)
    state = state.copyWith(
      isRegistered: false,
      username: 'Invitado',
      email: '',
    );
  }

  /// Registra una cuenta de usuario local de compatibilidad (Deprecado, usar registerUserInCloud)
  void registerUser(String username, String email) {
    state = state.copyWith(
      isRegistered: true,
      username: username,
      email: email,
    );
    _storageService.saveRegistrationDetails(
      isRegistered: true,
      username: username,
      email: email,
    );
    addCoins(150);
  }

  /// Añade monedas al perfil y las persiste.
  void addCoins(int amount) {
    final updatedCoins = state.coins + amount;
    state = state.copyWith(coins: updatedCoins);
    _storageService.saveCoins(updatedCoins);
    
    // Lanzar sincronización en segundo plano de manera asíncrona
    syncWithServer();
  }

  /// Deduce monedas del perfil. Retorna true si tiene fondos, de lo contrario false.
  bool deductCoins(int amount) {
    if (state.coins < amount) return false;
    final updatedCoins = state.coins - amount;
    state = state.copyWith(coins: updatedCoins);
    _storageService.saveCoins(updatedCoins);
    
    syncWithServer();
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
    } else {
      syncWithServer();
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

  /// Completa el Reto Diario: calcula racha, agrega fecha y otorga premios
  void completeDailyChallenge(String dateStr) {
    if (state.completedDailyDates.contains(dateStr)) return; // Ya se completó hoy

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
          newStreak = 1; // Se interrumpió la racha, reiniciamos a 1
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

    // Recompensa del Reto Diario: +50 S-Coins y +200 XP
    addCoins(50);
    addXp(200);

    // Desbloquear logro "Hábito Diario" si llega a 3 días
    if (newStreak >= 3) {
      unlockAchievement('constancia');
    }
  }

  /// Comprueba y gestiona las rachas de juego clásicas (si se ganan partidas normales).
  void checkDailyStreak() {
    final todayStr = DateTime.now().toIso8601String().substring(0, 10); // AAAA-MM-DD
    
    if (state.lastDailyPlayedDate == todayStr) {
      return; // Ya jugó hoy
    }

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

        if (newStreak >= 3) {
          unlockAchievement('constancia');
        }
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
}

// Proveedor global del Perfil de Usuario
final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ProfileNotifier(storage);
});
