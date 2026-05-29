import '../../../../core/utils/result.dart';
import '../entities/campaign_level.dart';

/// Contrato abstracto para el repositorio de la Campaña de Mapa Estelar.
/// Capa de Dominio (Domain Layer) - Define las acciones de negocio puras.
abstract class CampaignRepository {
  /// Obtiene la lista completa de planetas/niveles de la campaña estelar.
  Future<Result<List<CampaignLevel>>> getCampaignLevels();

  /// Reporta al servidor que el usuario ha completado un nivel estelar.
  Future<Result<void>> completeCampaignLevel(int levelNumber);
}
