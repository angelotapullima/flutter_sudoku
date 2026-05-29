import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../config/env_config.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../models/daily_mission_model.dart';

/// Contrato para la fuente de datos remota de misiones diarias.
abstract class MissionRemoteDataSource {
  /// Obtiene los datos en bruto de las misiones diarias.
  Future<List<DailyMissionModel>> getDailyMissions();

  /// Reporta el avance en una misión específica.
  Future<void> updateMissionProgress({
    required int missionId,
    required int increment,
  });
}

/// Implementación concreta de la fuente de datos remota usando http.Client y AuthLocalDataSource.
/// Capa de Datos (Data Layer) - Realiza las llamadas de red directas.
class MissionRemoteDataSourceImpl implements MissionRemoteDataSource {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;

  const MissionRemoteDataSourceImpl({
    required this.client,
    required this.authLocalDataSource,
  });

  @override
  Future<List<DailyMissionModel>> getDailyMissions() async {
    final token = await authLocalDataSource.getToken();
    final url = Uri.parse('${EnvConfig.baseUrl}/gamification/missions');
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await client.get(url, headers: headers).timeout(
          const Duration(seconds: 10),
        );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> list = data['missions'] ?? [];
      return list.map((m) => DailyMissionModel.fromJson(m)).toList();
    } else {
      final Map<String, dynamic> data = jsonDecode(response.body);
      throw Exception(
          data['error'] ?? 'Error al obtener las misiones del servidor.');
    }
  }

  @override
  Future<void> updateMissionProgress({
    required int missionId,
    required int increment,
  }) async {
    final token = await authLocalDataSource.getToken();
    final url = Uri.parse('${EnvConfig.baseUrl}/gamification/missions/update');
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final body = jsonEncode({
      'missionId': missionId,
      'increment': increment,
    });

    final response =
        await client.post(url, headers: headers, body: body).timeout(
              const Duration(seconds: 10),
            );

    if (response.statusCode != 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      throw Exception(data['error'] ??
          'Error al actualizar el progreso de la misión en el servidor.');
    }
  }
}
