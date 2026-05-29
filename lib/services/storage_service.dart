abstract class StorageService {
  /// Inicializa el servicio si es necesario (ej. cargar SharedPreferences).
  Future<void> init();

  /// Guarda las monedas del usuario.
  Future<void> saveCoins(int coins);

  /// Obtiene las monedas guardadas del usuario.
  int getCoins();

  /// Guarda la experiencia (XP) del usuario.
  Future<void> saveXp(int xp);

  /// Obtiene la experiencia (XP) guardada del usuario.
  int getXp();

  /// Guarda el nivel del usuario.
  Future<void> saveLevel(int level);

  /// Obtiene el nivel guardado del usuario.
  int getLevel();

  /// Guarda la lista de IDs de logros desbloqueados.
  Future<void> saveUnlockedAchievements(List<String> achievements);

  /// Obtiene la lista de logros desbloqueados.
  List<String> getUnlockedAchievements();

  /// Guarda la lista de temas estéticos comprados.
  Future<void> savePurchasedThemes(List<String> themes);

  /// Obtiene los temas estéticos comprados.
  List<String> getPurchasedThemes();

  /// Guarda el tema de color activo y si está en modo oscuro.
  Future<void> saveThemeSettings(
      {required String colorTheme, required bool isDarkMode});

  /// Obtiene el tema de color activo.
  String getActiveColorTheme();

  /// Obtiene si está en modo oscuro.
  bool getIsDarkMode();

  /// Guarda el mejor tiempo de resolución para una dificultad dada (en segundos).
  Future<void> saveBestTime(String difficulty, int seconds);

  /// Obtiene el mejor tiempo de resolución para una dificultad dada.
  int getBestTime(String difficulty);

  /// Guarda estadísticas generales: partidas iniciadas, partidas ganadas por dificultad.
  Future<void> saveGamesPlayed(String difficulty, int count);
  int getGamesPlayed(String difficulty);

  Future<void> saveGamesWon(String difficulty, int count);
  int getGamesWon(String difficulty);

  /// Guarda la racha diaria de juego.
  Future<void> saveDailyStreak(int streak);
  int getDailyStreak();

  /// Guarda la fecha del último Sudoku diario jugado (formato ISO).
  Future<void> saveLastDailyPlayedDate(String date);
  String getLastDailyPlayedDate();

  /// Guarda la lista de fechas de retos diarios completados.
  Future<void> saveCompletedDailyDates(List<String> dates);

  /// Obtiene la lista de fechas de retos diarios completados.
  List<String> getCompletedDailyDates();

  /// Guarda un Sudoku en progreso para reanudar más tarde.
  Future<void> saveActiveGame(String jsonGameData);

  /// Obtiene la partida de Sudoku guardada en progreso (o null si no hay).
  String? getActiveGame();

  /// Limpia la partida en progreso (cuando se completa o abandona).
  Future<void> clearActiveGame();

  /// Guarda el nivel de campaña.
  Future<void> saveCampaignLevel(int level);
  int getCampaignLevel();

  /// Guarda las cargas de Visión Verdadera.
  Future<void> saveVisionCharges(int charges);
  int getVisionCharges();

  /// Guarda las cargas de Reloj Estelar.
  Future<void> saveTimeFreezeCharges(int charges);
  int getTimeFreezeCharges();

  /// Guarda las cargas de Toque Divino.
  Future<void> saveDivineTouchCharges(int charges);
  int getDivineTouchCharges();

  /// Guarda la fecha de expiración del XP Boost.
  Future<void> saveXpBoostUntil(String? date);
  String? getXpBoostUntil();

  /// Guarda el borde de avatar activo.
  Future<void> saveActiveAvatarBorder(String border);
  String getActiveAvatarBorder();

  /// Guarda el título activo.
  Future<void> saveActiveTitle(String title);
  String getActiveTitle();

  /// Guarda las configuraciones personalizadas del juego
  Future<void> saveSettings({
    required bool showRemainingNumbers,
    required bool enableErrorLimit,
    required bool enableHighlighting,
    required bool enableVibration,
    required bool showTimer,
  });

  /// Obtiene si debe mostrar la cantidad restante en el pad de números
  bool getSettingShowRemainingNumbers();

  /// Obtiene si debe aplicar el límite estricto de 3 errores
  bool getSettingEnableErrorLimit();

  /// Obtiene si debe resaltar la cuadrícula de celda seleccionada (fila, columna, bloque y números iguales)
  bool getSettingEnableHighlighting();

  /// Obtiene si la vibración en errores está activa
  bool getSettingEnableVibration();

  /// Obtiene si debe mostrarse el temporizador de partida
  bool getSettingShowTimer();

  /// Guarda los detalles de registro del usuario
  Future<void> saveRegistrationDetails({
    required bool isRegistered,
    required String username,
    required String email,
  });

  /// Obtiene si el usuario está registrado
  bool getIsRegistered();

  /// Obtiene el nombre de usuario
  String getUsername();

  /// Obtiene el correo de registro
  String getEmail();

  /// Guarda si el banner de invitación de registro ha sido cerrado (dismissed).
  Future<void> saveSyncBannerDismissed(bool dismissed);

  /// Obtiene si el banner de invitación de registro ha sido cerrado.
  bool getSyncBannerDismissed();
}
