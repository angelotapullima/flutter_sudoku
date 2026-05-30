import 'dart:convert';

/// logger táctico ultra-premium de colores estelares para la consola de depuración.
/// Utiliza códigos de escape ANSI y Emojis RPG para un filtrado visual inmediato en VSCode.
class CosmicLogger {
  // Códigos de color ANSI para Dart
  static const String _ansiReset = '\x1B[0m';
  static const String _ansiRed = '\x1B[31m';
  static const String _ansiGreen = '\x1B[32m';
  static const String _ansiYellow = '\x1B[33m';
  static const String _ansiMagenta = '\x1B[35m';
  static const String _ansiCian = '\x1B[36m';
  static const String _ansiBrightWhite = '\x1B[97m';

  /// Log de éxito estelar (Verde)
  static void success(String message) {
    print('$_ansiGreen🟢 [ÉXITO] $message$_ansiReset');
  }

  /// Log de error crítico (Rojo)
  static void error(String message, [dynamic error]) {
    print(
        '$_ansiRed🔴 [ERROR] $message${error != null ? ": $error" : ""}$_ansiReset');
  }

  /// Log de advertencia (Amarillo)
  static void warning(String message) {
    print('$_ansiYellow🟡 [ADVERTENCIA] $message$_ansiReset');
  }

  /// Log de información general (Cian)
  static void info(String message) {
    print('$_ansiCian🔵 [INFO] $message$_ansiReset');
  }

  /// Log de depuración profunda (Magenta)
  static void debug(String message) {
    print('$_ansiMagenta🟣 [DEBUG] $message$_ansiReset');
  }

  /// Imprime un mapa JSON con un formato de color premium indentado
  static void json(String title, Map<String, dynamic> data) {
    try {
      final prettyJson = const JsonEncoder.withIndent('  ').convert(data);
      print('$_ansiBrightWhite🛸 [JSON] $title:\n$prettyJson$_ansiReset');
    } catch (_) {
      print('$_ansiBrightWhite🛸 [JSON] $title: $data$_ansiReset');
    }
  }
}
