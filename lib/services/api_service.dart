import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/env_config.dart';

class ApiService {
  // CONFIGURACIÓN DINÁMICA DE ENTORNO
  static const String baseUrl = EnvConfig.baseUrl;

  static const String _keyToken = 'sudoku_jwt_token';

  /// Helper privado para registrar logs legibles en la consola de debug
  static void _log(String type, String method, String path, {int? statusCode, String? error}) {
    final emoji = type == 'REQ' ? '📡 ──> [REQ]' : (error != null ? '❌ ──> [ERR]' : '📥 <── [RES]');
    final statusStr = statusCode != null ? ' | Código: $statusCode' : '';
    final errorStr = error != null ? ' | Detalle: $error' : '';
    print('$emoji $method $baseUrl$path$statusStr$errorStr');
  }

  /// Guarda el token JWT en el almacenamiento local seguro SharedPreferences
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  /// Recupera el token JWT guardado en local
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// Limpia el token de SharedPreferences (Cerrar sesión)
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
  }

  /// Obtiene los headers por defecto, agregando el token JWT si está disponible
  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// REGISTRAR UN NUEVO USUARIO
  /// Permite opcionalmente enviar el progreso local del invitado para migrarlo
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    Map<String, dynamic>? localProgress,
  }) async {
    final url = Uri.parse('$baseUrl/auth/register');
    final body = jsonEncode({
      'username': username,
      'email': email,
      'password': password,
      if (localProgress != null) 'localProgress': localProgress,
    });

    _log('REQ', 'POST', '/auth/register');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body,
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      _log('RES', 'POST', '/auth/register', statusCode: response.statusCode);

      if (response.statusCode == 201) {
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['error'] ?? 'Error desconocido al registrar.'};
      }
    } catch (e) {
      _log('ERR', 'POST', '/auth/register', error: e.toString());
      return {'success': false, 'message': 'No se pudo conectar con el servidor backend. Verifica tu conexión de red.'};
    }
  }

  /// INICIAR SESIÓN CON UNA CUENTA EXISTENTE
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final body = jsonEncode({
      'email': email,
      'password': password,
    });

    _log('REQ', 'POST', '/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body,
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      _log('RES', 'POST', '/auth/login', statusCode: response.statusCode);

      if (response.statusCode == 200) {
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['error'] ?? 'Credenciales incorrectas.'};
      }
    } catch (e) {
      _log('ERR', 'POST', '/auth/login', error: e.toString());
      return {'success': false, 'message': 'No se pudo conectar con el servidor backend.'};
    }
  }

  /// OBTENER EL PERFIL ACTUAL DEL SERVIDOR (Sin enviar datos locales)
  static Future<Map<String, dynamic>> getUserProfile() async {
    final url = Uri.parse('$baseUrl/profile');
    final headers = await _getHeaders();

    _log('REQ', 'GET', '/profile');

    try {
      final response = await http.get(
        url,
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      _log('RES', 'GET', '/profile', statusCode: response.statusCode);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data['profile']};
      } else {
        return {'success': false, 'message': data['error'] ?? 'Error al obtener perfil.'};
      }
    } catch (e) {
      _log('ERR', 'GET', '/profile', error: e.toString());
      return {'success': false, 'message': 'Sin conexión al servidor.'};
    }
  }

  /// SINCRONIZAR PROGRESO CON EL SERVIDOR
  static Future<Map<String, dynamic>> syncProfile({
    required Map<String, dynamic> localProgress,
  }) async {
    final url = Uri.parse('$baseUrl/profile/sync');
    final headers = await _getHeaders();
    final body = jsonEncode(localProgress);

    _log('REQ', 'POST', '/profile/sync');

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 12));

      final data = jsonDecode(response.body);
      _log('RES', 'POST', '/profile/sync', statusCode: response.statusCode);

      if (response.statusCode == 200) {
        if (data['profile'] != null) {
          final p = data['profile'];
          print('   📥 Perfil Recibido: Coins=${p['coins']}, Level=${p['level']}, XP=${p['xp']}');
        }
        return {'success': true, 'data': data['profile']};
      } else {
        return {'success': false, 'message': data['error'] ?? 'Error al sincronizar.'};
      }
    } catch (e) {
      _log('ERR', 'POST', '/profile/sync', error: e.toString());
      return {'success': false, 'message': 'Error de red al sincronizar progreso.'};
    }
  }

  /// OBTENER CLASIFICACIÓN GLOBAL (LEADERBOARD)
  /// - [type]: 'level' (general por nivel/xp) o 'speed' (mejores tiempos de resolución)
  /// - [difficulty]: 'Fácil', 'Medio', 'Difícil', 'Experto' (requerido si type='speed')
  static Future<Map<String, dynamic>> getLeaderboard({
    String type = 'level',
    String difficulty = 'Fácil',
  }) async {
    final url = Uri.parse('$baseUrl/leaderboard?type=$type&difficulty=$difficulty');
    
    _log('REQ', 'GET', '/leaderboard?type=$type&difficulty=$difficulty');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: 8));

      final data = jsonDecode(response.body);
      _log('RES', 'GET', '/leaderboard?type=$type&difficulty=$difficulty', statusCode: response.statusCode);

      if (response.statusCode == 200) {
        return {'success': true, 'leaderboard': data['leaderboard']};
      } else {
        return {'success': false, 'message': data['error'] ?? 'Error al cargar clasificación.'};
      }
    } catch (e) {
      _log('ERR', 'GET', '/leaderboard?type=$type&difficulty=$difficulty', error: e.toString());
      return {'success': false, 'message': 'Sin conexión al servidor de clasificaciones.'};
    }
  }
}
