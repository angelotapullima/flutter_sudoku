import '../../../../core/utils/result.dart';
import '../entities/leaderboard_player.dart';

/// Contrato abstracto que define las operaciones de datos necesarias para las clasificaciones.
/// La capa de dominio define este contrato, y la capa de datos es responsable de implementarlo.
abstract class LeaderboardRepository {
  /// Obtiene la clasificación global de jugadores de forma paginada y tipada.
  Future<Result<List<LeaderboardPlayer>>> getLeaderboard({
    required String type,
    required String difficulty,
    required int page,
    required int limit,
  });
}
