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
  Future<void> saveThemeSettings({required String colorTheme, required bool isDarkMode});
  
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

  /// Guarda un Sudoku en progreso para reanudar más tarde.
  Future<void> saveActiveGame(String jsonGameData);
  
  /// Obtiene la partida de Sudoku guardada en progreso (o null si no hay).
  String? getActiveGame();

  /// Limpia la partida en progreso (cuando se completa o abandona).
  Future<void> clearActiveGame();
}
