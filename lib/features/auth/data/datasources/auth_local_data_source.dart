import 'package:shared_preferences/shared_preferences.dart';

/// Interfaz para la persistencia local del token JWT de autenticación.
abstract class AuthLocalDataSource {
  /// Guarda el token JWT en local.
  Future<void> saveToken(String token);

  /// Recupera el token JWT guardado.
  Future<String?> getToken();

  /// Borra el token JWT guardado (Cierre de sesión).
  Future<void> clearToken();
}

/// Implementación concreta de la persistencia local usando SharedPreferences.
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _keyToken = 'sudoku_jwt_token';

  @override
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  @override
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  @override
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
  }
}
