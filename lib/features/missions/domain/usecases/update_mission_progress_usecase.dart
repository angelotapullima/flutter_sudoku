import '../../../../core/utils/result.dart';
import '../repositories/mission_repository.dart';

/// Caso de uso para actualizar el progreso de una misión diaria.
/// Capa de Dominio (Domain Layer) - Lógica de negocio atómica e independiente.
class UpdateMissionProgressUseCase {
  final MissionRepository repository;

  const UpdateMissionProgressUseCase(this.repository);

  Future<Result<void>> call({
    required int missionId,
    int increment = 1,
  }) async {
    return await repository.updateMissionProgress(
      missionId: missionId,
      increment: increment,
    );
  }
}
