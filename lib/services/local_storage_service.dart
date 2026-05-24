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
  static const String _keyCompletedDailyDates = 'sudoku_completed_daily_dates';
  static const String _keyActiveGame = 'sudoku_active_game_data';
  static const String _keyIsRegistered = 'sudoku_is_registered';
  static const String _keyUsername = 'sudoku_username';
  static const String _keyEmail = 'sudoku_email';

  // Claves para el sistema RPG e Inventario (Fase 4)
  static const String _keyCampaignLevel = 'sudoku_campaign_level';
  static const String _keyVisionCharges = 'sudoku_vision_charges';
  static const String _keyTimeFreezeCharges = 'sudoku_time_freeze_charges';
  static const String _keyDivineTouchCharges = 'sudoku_divine_touch_charges';
  static const String _keyXpBoostUntil = 'sudoku_xp_boost_until';
  static const String _keyAvatarBorder = 'sudoku_avatar_border';
  static const String _keyActiveTitle = 'sudoku_active_title';

  // Claves para configuraciones personalizadas del juego
  static const String _keyShowRemaining = 'settings_show_remaining';
  static const String _keyErrorLimit = 'settings_error_limit';
  static const String _keyHighlighting = 'settings_highlighting';
  static const String _keyVibration = 'settings_vibration';
  static const String _keyShowTimer = 'settings_show_timer';

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
    return _prefs.getInt(_keyCoins) ?? 100;
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
    return _prefs.getStringList(_keyThemes) ??
        ['azul']; // El tema azul es el inicial gratuito
  }

  @override
  Future<void> saveThemeSettings(
      {required String colorTheme, required bool isDarkMode}) async {
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
    return _prefs.getInt('sudoku_best_time_$difficulty') ??
        0; // 0 significa sin récord
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
  Future<void> saveCompletedDailyDates(List<String> dates) async {
    await _prefs.setStringList(_keyCompletedDailyDates, dates);
  }

  @override
  List<String> getCompletedDailyDates() {
    return _prefs.getStringList(_keyCompletedDailyDates) ?? [];
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

  @override
  Future<void> saveCampaignLevel(int level) async {
    await _prefs.setInt(_keyCampaignLevel, level);
  }

  @override
  int getCampaignLevel() {
    return _prefs.getInt(_keyCampaignLevel) ?? 1;
  }

  @override
  Future<void> saveVisionCharges(int charges) async {
    await _prefs.setInt(_keyVisionCharges, charges);
  }

  @override
  int getVisionCharges() {
    return _prefs.getInt(_keyVisionCharges) ?? 3;
  }

  @override
  Future<void> saveTimeFreezeCharges(int charges) async {
    await _prefs.setInt(_keyTimeFreezeCharges, charges);
  }

  @override
  int getTimeFreezeCharges() {
    return _prefs.getInt(_keyTimeFreezeCharges) ?? 2;
  }

  @override
  Future<void> saveDivineTouchCharges(int charges) async {
    await _prefs.setInt(_keyDivineTouchCharges, charges);
  }

  @override
  int getDivineTouchCharges() {
    return _prefs.getInt(_keyDivineTouchCharges) ?? 1;
  }

  @override
  Future<void> saveXpBoostUntil(String? date) async {
    if (date == null) {
      await _prefs.remove(_keyXpBoostUntil);
    } else {
      await _prefs.setString(_keyXpBoostUntil, date);
    }
  }

  @override
  String? getXpBoostUntil() {
    return _prefs.getString(_keyXpBoostUntil);
  }

  @override
  Future<void> saveActiveAvatarBorder(String border) async {
    await _prefs.setString(_keyAvatarBorder, border);
  }

  @override
  String getActiveAvatarBorder() {
    return _prefs.getString(_keyAvatarBorder) ?? 'none';
  }

  @override
  Future<void> saveActiveTitle(String title) async {
    await _prefs.setString(_keyActiveTitle, title);
  }

  @override
  String getActiveTitle() {
    return _prefs.getString(_keyActiveTitle) ?? '';
  }

  @override
  Future<void> saveSettings({
    required bool showRemainingNumbers,
    required bool enableErrorLimit,
    required bool enableHighlighting,
    required bool enableVibration,
    required bool showTimer,
  }) async {
    await _prefs.setBool(_keyShowRemaining, showRemainingNumbers);
    await _prefs.setBool(_keyErrorLimit, enableErrorLimit);
    await _prefs.setBool(_keyHighlighting, enableHighlighting);
    await _prefs.setBool(_keyVibration, enableVibration);
    await _prefs.setBool(_keyShowTimer, showTimer);
  }

  @override
  bool getSettingShowRemainingNumbers() =>
      _prefs.getBool(_keyShowRemaining) ?? true;

  @override
  bool getSettingEnableErrorLimit() => _prefs.getBool(_keyErrorLimit) ?? true;

  @override
  bool getSettingEnableHighlighting() =>
      _prefs.getBool(_keyHighlighting) ?? true;

  @override
  bool getSettingEnableVibration() => _prefs.getBool(_keyVibration) ?? true;

  @override
  bool getSettingShowTimer() => _prefs.getBool(_keyShowTimer) ?? true;

  @override
  Future<void> saveRegistrationDetails({
    required bool isRegistered,
    required String username,
    required String email,
  }) async {
    await _prefs.setBool(_keyIsRegistered, isRegistered);
    await _prefs.setString(_keyUsername, username);
    await _prefs.setString(_keyEmail, email);
  }

  @override
  bool getIsRegistered() {
    return _prefs.getBool(_keyIsRegistered) ?? false;
  }

  @override
  String getUsername() {
    return _prefs.getString(_keyUsername) ?? 'Invitado';
  }

  @override
  String getEmail() {
    return _prefs.getString(_keyEmail) ?? '';
  }
}
