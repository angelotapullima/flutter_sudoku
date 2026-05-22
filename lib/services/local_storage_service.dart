import 'package:shared_preferences/shared_preferences.dart';
import 'storage_service.dart';

class LocalStorageService implements StorageService {
  late final SharedPreferences _prefs;

  // Claves para SharedPreferences
  static const String _keyCoins = 'sudoku_coins';
  static const String _keyXp = 'sudoku_xp';
  static const String _keyLevel = 'sudoku_level';
  static const String _keyAchievements = 'sudoku_achievements';
  static const String _keyThemes = 'sudoku_themes';
  static const String _keyActiveTheme = 'sudoku_active_theme';
  static const String _keyDarkMode = 'sudoku_dark_mode';
  static const String _keyStreak = 'sudoku_streak';
  static const String _keyLastDailyDate = 'sudoku_last_daily_date';
  static const String _keyActiveGame = 'sudoku_active_game_data';

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> saveCoins(int coins) async {
    await _prefs.setInt(_keyCoins, coins);
  }

  @override
  int getCoins() {
    return _prefs.getInt(_keyCoins) ?? 100; // 100 monedas de regalo iniciales
  }

  @override
  Future<void> saveXp(int xp) async {
    await _prefs.setInt(_keyXp, xp);
  }

  @override
  int getXp() {
    return _prefs.getInt(_keyXp) ?? 0;
  }

  @override
  Future<void> saveLevel(int level) async {
    await _prefs.setInt(_keyLevel, level);
  }

  @override
  int getLevel() {
    return _prefs.getInt(_keyLevel) ?? 1;
  }

  @override
  Future<void> saveUnlockedAchievements(List<String> achievements) async {
    await _prefs.setStringList(_keyAchievements, achievements);
  }

  @override
  List<String> getUnlockedAchievements() {
    return _prefs.getStringList(_keyAchievements) ?? [];
  }

  @override
  Future<void> savePurchasedThemes(List<String> themes) async {
    await _prefs.setStringList(_keyThemes, themes);
  }

  @override
  List<String> getPurchasedThemes() {
    return _prefs.getStringList(_keyThemes) ?? ['azul']; // El tema azul es el inicial gratuito
  }

  @override
  Future<void> saveThemeSettings({required String colorTheme, required bool isDarkMode}) async {
    await _prefs.setString(_keyActiveTheme, colorTheme);
    await _prefs.setBool(_keyDarkMode, isDarkMode);
  }

  @override
  String getActiveColorTheme() {
    return _prefs.getString(_keyActiveTheme) ?? 'azul';
  }

  @override
  bool getIsDarkMode() {
    return _prefs.getBool(_keyDarkMode) ?? false; // Modo claro por defecto
  }

  @override
  Future<void> saveBestTime(String difficulty, int seconds) async {
    await _prefs.setInt('sudoku_best_time_$difficulty', seconds);
  }

  @override
  int getBestTime(String difficulty) {
    return _prefs.getInt('sudoku_best_time_$difficulty') ?? 0; // 0 significa sin récord
  }

  @override
  Future<void> saveGamesPlayed(String difficulty, int count) async {
    await _prefs.setInt('sudoku_played_$difficulty', count);
  }

  @override
  int getGamesPlayed(String difficulty) {
    return _prefs.getInt('sudoku_played_$difficulty') ?? 0;
  }

  @override
  Future<void> saveGamesWon(String difficulty, int count) async {
    await _prefs.setInt('sudoku_won_$difficulty', count);
  }

  @override
  int getGamesWon(String difficulty) {
    return _prefs.getInt('sudoku_won_$difficulty') ?? 0;
  }

  @override
  Future<void> saveDailyStreak(int streak) async {
    await _prefs.setInt(_keyStreak, streak);
  }

  @override
  int getDailyStreak() {
    return _prefs.getInt(_keyStreak) ?? 0;
  }

  @override
  Future<void> saveLastDailyPlayedDate(String date) async {
    await _prefs.setString(_keyLastDailyDate, date);
  }

  @override
  String getLastDailyPlayedDate() {
    return _prefs.getString(_keyLastDailyDate) ?? '';
  }

  @override
  Future<void> saveActiveGame(String jsonGameData) async {
    await _prefs.setString(_keyActiveGame, jsonGameData);
  }

  @override
  String? getActiveGame() {
    return _prefs.getString(_keyActiveGame);
  }

  @override
  Future<void> clearActiveGame() async {
    await _prefs.remove(_keyActiveGame);
  }
}
