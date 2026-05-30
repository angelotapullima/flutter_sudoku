class EnvConfig {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://apisudokudev.anked.dev/api',
  );

  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'Sudoku Game',
  );

  static const String env = String.fromEnvironment(
    'ENV',
    defaultValue: 'local',
  );

  static const String vapidKey = String.fromEnvironment(
    'VAPID_KEY',
    defaultValue: '',
  );

  static bool get isProd => env == 'prod';
  static bool get isDev => env == 'dev';
  static bool get isLocal => env == 'local';
}
