class EnvConfig {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );
  
  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'Sudoku Game',
  );
  
  static const String env = String.fromEnvironment(
    'ENV',
    defaultValue: 'local',
  );

  static bool get isProd => env == 'prod';
  static bool get isDev => env == 'dev';
  static bool get isLocal => env == 'local';
}
