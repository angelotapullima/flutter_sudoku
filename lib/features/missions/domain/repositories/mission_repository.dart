import '../../../../core/utils/result.dart';
import '../entities/daily_mission.dart';

/// Contrato abstracto para el repositorio de Misiones Diarias.
/// Capa de Dominio (Domain Layer) - Define el qué, no el cómo.
abstract class MissionRepository {
  /// Obtiene el tablón de misiones diarias activas.
  Future<Result<List<DailyMission>>> getDailyMissions();

  /// Informa al servidor sobre el progreso incremental en una misión.
  Future<Result<void>> updateMissionProgress({
    required int missionId,
    required int increment,
  });
}
