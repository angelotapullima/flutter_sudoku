import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/env_config.dart';

class ApiService {
  // CONFIGURACIÓN DINÁMICA DE ENTORNO
  static const String baseUrl = EnvConfig.baseUrl;

  static const String _keyToken = 'sudoku_jwt_token';

  /// Helper privado para registrar logs legibles en la consola de debug
  static void _log(String type, String method, String path, {int? statusCode, String? error, String? responseBody}) {
    final emoji = type == 'REQ' ? '📡 ──> [REQ]' : (error != null ? '❌ ──> [ERR]' : '📥 <── [RES]');
    final statusStr = statusCode != null ? ' | Código: $statusCode' : '';
    final errorStr = error != null ? ' | Detalle: $error' : '';
    // Imprimimos la URL completa para facilitar el debug
    print('$emoji $method $baseUrl$path$statusStr$errorStr');
    if (responseBody != null) {
      print('   📜 Body: $responseBody');
    }
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
      _log('RES', 'POST', '/auth/register', statusCode: response.statusCode, responseBody: response.body);

      if (response.statusCode == 201) {
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        return {'success': true, 'data': data, 'status': response.statusCode};
      } else {
        return {'success': false, 'message': data['error'] ?? 'Error desconocido al registrar.', 'status': response.statusCode};
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
      _log('RES', 'POST', '/auth/login', statusCode: response.statusCode, responseBody: response.body);

      if (response.statusCode == 200) {
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        return {'success': true, 'data': data, 'status': response.statusCode};
      } else {
        return {'success': false, 'message': data['error'] ?? 'Credenciales incorrectas.', 'status': response.statusCode};
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
      _log('RES', 'GET', '/profile', statusCode: response.statusCode, responseBody: response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data['profile'], 'status': 200};
      } else {
        return {'success': false, 'message': data['error'] ?? 'Error al obtener perfil.', 'status': response.statusCode};
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
      _log('RES', 'POST', '/profile/sync', statusCode: response.statusCode, responseBody: response.body);

      if (response.statusCode == 200) {
        if (data['profile'] != null) {
          final p = data['profile'];
          print('   📥 Perfil Recibido: Coins=${p['coins']}, Level=${p['level']}, XP=${p['xp']}');
        }
        return {'success': true, 'data': data['profile'], 'status': 200};
      } else {
        return {'success': false, 'message': data['error'] ?? 'Error al sincronizar.', 'status': response.statusCode};
      }
    } catch (e) {
      _log('ERR', 'POST', '/profile/sync', error: e.toString());
      return {'success': false, 'message': 'Error de red al sincronizar progreso.'};
    }
  }

  /// OBTENER CLASIFICACIÓN GLOBAL (LEADERBOARD)
  static Future<Map<String, dynamic>> getLeaderboard({
    String type = 'level',
    String difficulty = 'Fácil',
  }) async {
    final url = Uri.parse('$baseUrl/leaderboard?type=$type&difficulty=$difficulty');
    final headers = await _getHeaders();
    
    _log('REQ', 'GET', '/leaderboard?type=$type&difficulty=$difficulty');

    try {
      final response = await http.get(
        url,
        headers: headers,
      ).timeout(const Duration(seconds: 8));

      final data = jsonDecode(response.body);
      _log('RES', 'GET', '/leaderboard?type=$type&difficulty=$difficulty', statusCode: response.statusCode, responseBody: response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'leaderboard': data['leaderboard'], 'status': 200};
      } else {
        return {'success': false, 'message': data['error'] ?? 'Error al cargar clasificación.', 'status': response.statusCode};
      }
    } catch (e) {
      _log('ERR', 'GET', '/leaderboard', error: e.toString());
      return {'success': false, 'message': 'Sin conexión al servidor.'};
    }
  }

  // --- NUEVOS MÉTODOS DE GAMIFICACIÓN ---

  /// Crear un nuevo torneo comunitario
  static Future<Map<String, dynamic>> createTournament({
    required String title,
    required String difficulty,
    required String puzzleData,
    required String solutionData,
  }) async {
    final url = Uri.parse('$baseUrl/gamification/tournament/create');
    final headers = await _getHeaders();
    final body = jsonEncode({
      'title': title,
      'difficulty': difficulty,
      'puzzleData': puzzleData,
      'solutionData': solutionData,
    });

    _log('REQ', 'POST', '/gamification/tournament/create');

    try {
      final response = await http.post(url, headers: headers, body: body).timeout(const Duration(seconds: 10));
      final data = jsonDecode(response.body);
      _log('RES', 'POST', '/gamification/tournament/create', statusCode: response.statusCode, responseBody: response.body);
      if (response.statusCode == 201) return {'success': true, 'tournament': data['tournament']};
      return {'success': false, 'message': data['error'] ?? 'Error al crear torneo.'};
    } catch (e) {
      return {'success': false, 'message': 'Sin conexión.'};
    }
  }

  /// Obtener el torneo global activo y su ranking
  static Future<Map<String, dynamic>> getActiveTournament() async {
    final url = Uri.parse('$baseUrl/gamification/tournament');
    final headers = await _getHeaders();
    _log('REQ', 'GET', '/gamification/tournament');

    try {
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 10));
      final data = jsonDecode(response.body);
      _log('RES', 'GET', '/gamification/tournament', statusCode: response.statusCode, responseBody: response.body);
      if (response.statusCode == 200) return {'success': true, 'data': data};
      return {'success': false, 'message': data['message'] ?? 'No hay torneos.'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión.'};
    }
  }

  /// Enviar resultado de participación en torneo
  static Future<Map<String, dynamic>> submitTournamentResult(int tournamentId, int time, int errors) async {
    final url = Uri.parse('$baseUrl/gamification/tournament/submit');
    final headers = await _getHeaders();
    final body = jsonEncode({'tournamentId': tournamentId, 'timeInSeconds': time, 'errors': errors});
    _log('REQ', 'POST', '/gamification/tournament/submit');

    try {
      final response = await http.post(url, headers: headers, body: body).timeout(const Duration(seconds: 10));
      _log('RES', 'POST', '/gamification/tournament/submit', statusCode: response.statusCode, responseBody: response.body);
      return {'success': response.statusCode == 200};
    } catch (e) {
      return {'success': false};
    }
  }

  /// Obtener misiones diarias asignadas al usuario
  static Future<Map<String, dynamic>> getDailyMissions() async {
    final url = Uri.parse('$baseUrl/gamification/missions');
    final headers = await _getHeaders();
    _log('REQ', 'GET', '/gamification/missions');

    try {
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 10));
      final data = jsonDecode(response.body);
      _log('RES', 'GET', '/gamification/missions', statusCode: response.statusCode, responseBody: response.body);
      if (response.statusCode == 200) return {'success': true, 'missions': data['missions']};
      return {'success': false};
    } catch (e) {
      return {'success': false};
    }
  }

  /// Actualizar progreso de una misión específica
  static Future<Map<String, dynamic>> updateMissionProgress(int missionId, int increment) async {
    final url = Uri.parse('$baseUrl/gamification/missions/update');
    final headers = await _getHeaders();
    final body = jsonEncode({'missionId': missionId, 'increment': increment});
    _log('REQ', 'POST', '/gamification/missions/update');

    try {
      final response = await http.post(url, headers: headers, body: body).timeout(const Duration(seconds: 10));
      _log('RES', 'POST', '/gamification/missions/update', statusCode: response.statusCode, responseBody: response.body);
      return {'success': response.statusCode == 200};
    } catch (e) {
      return {'success': false};
    }
  }

  /// Obtener niveles del Mapa Estelar (Campaña)
  static Future<Map<String, dynamic>> getCampaignLevels() async {
    final url = Uri.parse('$baseUrl/profile/campaign/levels');
    _log('REQ', 'GET', '/profile/campaign/levels');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      final data = jsonDecode(response.body);
      _log('RES', 'GET', '/profile/campaign/levels', statusCode: response.statusCode, responseBody: response.body);
      if (response.statusCode == 200) return {'success': true, 'levels': data['levels']};
      return {'success': false};
    } catch (e) {
      return {'success': false};
    }
  }

  /// Marcar nivel de campaña como completado
  static Future<Map<String, dynamic>> completeCampaignLevel(int levelNumber) async {
    final url = Uri.parse('$baseUrl/profile/campaign/complete');
    final headers = await _getHeaders();
    final body = jsonEncode({'levelCompleted': levelNumber});
    _log('REQ', 'POST', '/profile/campaign/complete');

    try {
      final response = await http.post(url, headers: headers, body: body).timeout(const Duration(seconds: 10));
      final data = jsonDecode(response.body);
      _log('RES', 'POST', '/profile/campaign/complete', statusCode: response.statusCode, responseBody: response.body);
      return {'success': response.statusCode == 200, 'data': data};
    } catch (e) {
      return {'success': false};
    }
  }

  // --- SERVICIOS DE CLANES (Fase 4) ---

  static Future<Map<String, dynamic>> createClan(String name, String tag, String description) async {
    final url = Uri.parse('$baseUrl/clans/create');
    final headers = await _getHeaders();
    final body = jsonEncode({'name': name, 'tag': tag, 'description': description});
    _log('REQ', 'POST', '/clans/create');

    try {
      final response = await http.post(url, headers: headers, body: body).timeout(const Duration(seconds: 10));
      _log('RES', 'POST', '/clans/create', statusCode: response.statusCode, responseBody: response.body);
      return {
        'success': response.statusCode == 201, 
        'error': jsonDecode(response.body)['error'],
        'status': response.statusCode
      };
    } catch (e) {
      return {'success': false, 'error': 'Sin conexión.', 'status': 500};
    }
  }

  static Future<Map<String, dynamic>> listClans() async {
    final url = Uri.parse('$baseUrl/clans/list');
    final headers = await _getHeaders();
    _log('REQ', 'GET', '/clans/list');

    try {
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 10));
      _log('RES', 'GET', '/clans/list', statusCode: response.statusCode, responseBody: response.body);
      return {
        'success': response.statusCode == 200, 
        'clans': jsonDecode(response.body)['clans'],
        'status': response.statusCode
      };
    } catch (e) {
      return {'success': false, 'status': 500};
    }
  }

  static Future<Map<String, dynamic>> joinClan(int clanId) async {
    final url = Uri.parse('$baseUrl/clans/join/$clanId');
    final headers = await _getHeaders();
    _log('REQ', 'POST', '/clans/join/$clanId');

    try {
      final response = await http.post(url, headers: headers).timeout(const Duration(seconds: 10));
      _log('RES', 'POST', '/clans/join/$clanId', statusCode: response.statusCode, responseBody: response.body);
      return {
        'success': response.statusCode == 200, 
        'error': jsonDecode(response.body)['error'],
        'status': response.statusCode
      };
    } catch (e) {
      return {'success': false, 'error': 'Sin conexión.', 'status': 500};
    }
  }

  static Future<Map<String, dynamic>> getMyClan() async {
    final url = Uri.parse('$baseUrl/clans/my-clan');
    final headers = await _getHeaders();
    _log('REQ', 'GET', '/clans/my-clan');

    try {
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 10));
      _log('RES', 'GET', '/clans/my-clan', statusCode: response.statusCode, responseBody: response.body);
      final data = jsonDecode(response.body);
      return {
        ...data,
        'status': response.statusCode
      };
    } catch (e) {
      return {'inClan': false, 'status': 500};
    }
  }

  static Future<Map<String, dynamic>> leaveClan() async {
    final url = Uri.parse('$baseUrl/clans/leave');
    final headers = await _getHeaders();
    _log('REQ', 'POST', '/clans/leave');

    try {
      final response = await http.post(url, headers: headers).timeout(const Duration(seconds: 10));
      _log('RES', 'POST', '/clans/leave', statusCode: response.statusCode, responseBody: response.body);
      return {
        'success': response.statusCode == 200, 
        'status': response.statusCode
      };
    } catch (e) {
      return {'success': false, 'status': 500};
    }
  }

  static Future<bool> sendClanMessage(String message) async {
    final url = Uri.parse('$baseUrl/clans/messages/send');
    final headers = await _getHeaders();
    final body = jsonEncode({'message': message});
    _log('REQ', 'POST', '/clans/messages/send');

    try {
      final response = await http.post(url, headers: headers, body: body).timeout(const Duration(seconds: 8));
      _log('RES', 'POST', '/clans/messages/send', statusCode: response.statusCode, responseBody: response.body);
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
