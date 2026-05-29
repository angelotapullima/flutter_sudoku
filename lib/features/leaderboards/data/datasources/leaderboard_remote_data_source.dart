import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../config/env_config.dart';
import '../../../../services/api_service.dart';
import '../models/leaderboard_player_model.dart';

/// Contrato para la fuente de datos remota de clasificaciones.
abstract class LeaderboardRemoteDataSource {
  /// Obtiene los datos en bruto (JSON list) de clasificaciones desde el servidor.
  Future<List<LeaderboardPlayerModel>> getLeaderboard({
    required String type,
    required String difficulty,
    required int page,
    required int limit,
  });
}

/// Implementación concreta de la fuente de datos remota utilizando el cliente HTTP nativo.
class LeaderboardRemoteDataSourceImpl implements LeaderboardRemoteDataSource {
  final http.Client client;

  const LeaderboardRemoteDataSourceImpl({required this.client});

  @override
  Future<List<LeaderboardPlayerModel>> getLeaderboard({
    required String type,
    required String difficulty,
    required int page,
    required int limit,
  }) async {
    final token = await ApiService.getToken();
    final url = Uri.parse(
      '${EnvConfig.baseUrl}/leaderboard?type=$type&difficulty=$difficulty&page=$page&limit=$limit',
    );
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await client.get(url, headers: headers).timeout(
          const Duration(seconds: 8),
        );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> list = data['leaderboard'] ?? [];
      return list.map((item) => LeaderboardPlayerModel.fromJson(item)).toList();
    } else {
      final Map<String, dynamic> data = jsonDecode(response.body);
      throw Exception(
          data['error'] ?? 'Error al cargar clasificación del servidor.');
    }
  }
}
