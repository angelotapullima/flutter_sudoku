import 'dart:io';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/leaderboard_player.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../datasources/leaderboard_remote_data_source.dart';

/// Implementación concreta de 'LeaderboardRepository'.
/// Su rol es procesar los datos, coordinar local/remoto y capturar excepciones mapeándolas a 'Failure'.
class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final LeaderboardRemoteDataSource remoteDataSource;

  const LeaderboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<List<LeaderboardPlayer>>> getLeaderboard({
    required String type,
    required String difficulty,
    required int page,
    required int limit,
  }) async {
    try {
      final List<LeaderboardPlayer> players =
          await remoteDataSource.getLeaderboard(
        type: type,
        difficulty: difficulty,
        page: page,
        limit: limit,
      );
      return Success(players);
    } on SocketException {
      return const FailureResult(NetworkFailure());
    } catch (e) {
      // Remover prefijos de excepción genéricos para un mensaje limpio en UI
      final cleanMsg = e.toString().replaceAll('Exception: ', '');
      return FailureResult(ServerFailure(cleanMsg));
    }
  }
}
