import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/daily_mission.dart';
import '../../domain/repositories/mission_repository.dart';
import '../datasources/mission_remote_data_source.dart';

/// Implementación del repositorio concreto de Misiones Diarias.
/// Capa de Datos (Data Layer) - Orquesta llamadas a fuentes y transforma errores a fallos tipados de negocio.
class MissionRepositoryImpl implements MissionRepository {
  final MissionRemoteDataSource remoteDataSource;

  const MissionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<List<DailyMission>>> getDailyMissions() async {
    try {
      final modelsList = await remoteDataSource.getDailyMissions();
      // Debido a la covarianza de Dart, List<DailyMissionModel> es asignable a List<DailyMission>
      return Success(modelsList);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateMissionProgress({
    required int missionId,
    required int increment,
  }) async {
    try {
      await remoteDataSource.updateMissionProgress(
        missionId: missionId,
        increment: increment,
      );
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }
}
