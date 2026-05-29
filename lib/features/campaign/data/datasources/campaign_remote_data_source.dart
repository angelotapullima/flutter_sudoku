import '../../../../services/api_service.dart';
import '../models/campaign_level_model.dart';

/// Interfaz para la fuente de datos remota de la campaña.
abstract class CampaignRemoteDataSource {
  /// Obtiene los niveles de campaña desde el servidor.
  Future<List<CampaignLevelModel>> getCampaignLevels();

  /// Reporta un nivel completado al servidor.
  Future<void> completeCampaignLevel(int levelNumber);
}

/// Implementación de la fuente de datos remota utilizando [ApiService].
class CampaignRemoteDataSourceImpl implements CampaignRemoteDataSource {
  @override
  Future<List<CampaignLevelModel>> getCampaignLevels() async {
    final response = await ApiService.getCampaignLevels();

    if (response['success'] == true) {
      final List<dynamic> levelsJson = response['levels'];
      return levelsJson
          .map((json) => CampaignLevelModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Error al obtener niveles de campaña del servidor');
    }
  }

  @override
  Future<void> completeCampaignLevel(int levelNumber) async {
    final response = await ApiService.completeCampaignLevel(levelNumber);

    if (response['success'] != true) {
      throw Exception('Error al marcar nivel de campaña como completado');
    }
  }
}
