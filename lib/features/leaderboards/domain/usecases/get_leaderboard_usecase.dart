import '../../../../core/utils/result.dart';
import '../entities/leaderboard_player.dart';
import '../repositories/leaderboard_repository.dart';

/// Caso de uso específico para obtener el ranking de clasificaciones.
/// Sigue el principio de responsabilidad única (Single Responsibility Principle).
class GetLeaderboardUseCase {
  final LeaderboardRepository _repository;

  const GetLeaderboardUseCase(this._repository);

  /// Ejecuta el caso de uso. Al usar la función 'call', se puede invocar
  /// directamente como `getLeaderboardUseCase(...)`.
  Future<Result<List<LeaderboardPlayer>>> call({
    required String type,
    required String difficulty,
    required int page,
    required int limit,
  }) {
    return _repository.getLeaderboard(
      type: type,
      difficulty: difficulty,
      page: page,
      limit: limit,
    );
  }
}
