import '../../../../core/utils/result.dart';
import '../entities/daily_mission.dart';
import '../repositories/mission_repository.dart';

/// Caso de uso para descargar la lista de misiones diarias activas.
/// Capa de Dominio (Domain Layer) - Lógica de negocio atómica e independiente.
class GetDailyMissionsUseCase {
  final MissionRepository repository;

  const GetDailyMissionsUseCase(this.repository);

  Future<Result<List<DailyMission>>> call() async {
    return await repository.getDailyMissions();
  }
}
