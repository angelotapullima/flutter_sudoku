import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/campaign_level.dart';
import '../../domain/repositories/campaign_repository.dart';
import '../datasources/campaign_remote_data_source.dart';

/// Implementación concreta del repositorio de Campaña.
/// Capa de Datos (Data Layer) - Coordina DataSource y mapeo de errores.
class CampaignRepositoryImpl implements CampaignRepository {
  final CampaignRemoteDataSource remoteDataSource;

  const CampaignRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<List<CampaignLevel>>> getCampaignLevels() async {
    try {
      final levels = await remoteDataSource.getCampaignLevels();
      return Success(levels);
    } on Exception catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    } catch (e) {
      return FailureResult(ServerFailure('Ocurrió un error inesperado: $e'));
    }
  }

  @override
  Future<Result<void>> completeCampaignLevel(int levelNumber) async {
    try {
      await remoteDataSource.completeCampaignLevel(levelNumber);
      return const Success(null);
    } on Exception catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    } catch (e) {
      return FailureResult(ServerFailure('Ocurrió un error inesperado: $e'));
    }
  }
}
