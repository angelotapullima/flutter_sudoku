import '../../../../core/utils/result.dart';
import '../entities/campaign_level.dart';
import '../repositories/campaign_repository.dart';

/// Caso de uso para obtener todos los niveles del Mapa Estelar.
/// Capa de Dominio (Domain Layer) - Lógica de negocio atómica e independiente.
class GetCampaignLevelsUseCase {
  final CampaignRepository repository;

  const GetCampaignLevelsUseCase(this.repository);

  Future<Result<List<CampaignLevel>>> call() async {
    return await repository.getCampaignLevels();
  }
}
