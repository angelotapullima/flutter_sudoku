import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../config/env_config.dart';
import '../models/user_session_model.dart';

/// Interfaz para las peticiones de red del módulo de autenticación.
abstract class AuthRemoteDataSource {
  /// Realiza la petición de inicio de sesión contra el servidor.
  Future<UserSessionModel> login({
    required String email,
    required String password,
  });

  /// Realiza el registro de usuario en la nube con el progreso local inicial.
  Future<UserSessionModel> register({
    required String username,
    required String email,
    required String password,
    Map<String, dynamic>? localProgress,
  });

  /// Recupera los datos de perfil del usuario utilizando un token JWT específico.
  Future<UserSessionModel> getCurrentProfile(String token);
}

/// Implementación concreta de la fuente de datos remota de autenticación.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  static const String _baseUrl = EnvConfig.baseUrl;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<UserSessionModel> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/login');
    final response = await client
        .post(
          url,
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final token = data['token'] as String?;
      return UserSessionModel.fromJson(data, token: token);
    } else {
      throw Exception(
          data['error'] ?? 'Credenciales incorrectas o error en servidor.');
    }
  }

  @override
  Future<UserSessionModel> register({
    required String username,
    required String email,
    required String password,
    Map<String, dynamic>? localProgress,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/register');
    final response = await client
        .post(
          url,
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'username': username,
            'email': email,
            'password': password,
            if (localProgress != null) 'localProgress': localProgress,
          }),
        )
        .timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      final token = data['token'] as String?;
      return UserSessionModel.fromJson(data, token: token);
    } else {
      throw Exception(
          data['error'] ?? 'Fallo al registrar usuario en la nube.');
    }
  }

  @override
  Future<UserSessionModel> getCurrentProfile(String token) async {
    final url = Uri.parse('$_baseUrl/profile');
    final response = await client.get(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return UserSessionModel.fromJson(data, token: token);
    } else {
      throw Exception(data['error'] ?? 'Sesión inválida o expirada.');
    }
  }
}
