import '../../../../core/utils/result.dart';
import '../repositories/campaign_repository.dart';

/// Caso de uso para marcar un nivel estelar como completado en el servidor.
/// Capa de Dominio (Domain Layer) - Lógica de negocio atómica e independiente.
class CompleteCampaignLevelUseCase {
  final CampaignRepository repository;

  const CompleteCampaignLevelUseCase(this.repository);

  Future<Result<void>> call(int levelNumber) async {
    return await repository.completeCampaignLevel(levelNumber);
  }
}
