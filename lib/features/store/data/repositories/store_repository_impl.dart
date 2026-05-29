import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/store_repository.dart';
import '../datasources/store_remote_data_source.dart';

/// Implementación concreta del repositorio de la Tienda RPG.
/// Capa de Datos (Data Layer) - Realiza el control de excepciones y los envuelve en Result.
class StoreRepositoryImpl implements StoreRepository {
  final StoreRemoteDataSource remoteDataSource;

  const StoreRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<void>> purchaseItem({
    required String itemId,
    required int cost,
    required String type,
  }) async {
    try {
      await remoteDataSource.purchaseItem(
        itemId: itemId,
        cost: cost,
        type: type,
      );
      return const Success(null);
    } on Exception catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    } catch (e) {
      return FailureResult(ServerFailure(
          'Ocurrió un error inesperado al realizar la compra: $e'));
    }
  }
}
