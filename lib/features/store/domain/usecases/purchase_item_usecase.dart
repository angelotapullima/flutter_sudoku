import '../../../../core/utils/result.dart';
import '../repositories/store_repository.dart';

/// Caso de uso para realizar la compra de un artículo de la tienda RPG.
/// Capa de Dominio (Domain Layer) - Lógica de negocio atómica e independiente.
class PurchaseItemUseCase {
  final StoreRepository repository;

  const PurchaseItemUseCase(this.repository);

  Future<Result<void>> call({
    required String itemId,
    required int cost,
    required String type,
  }) async {
    return await repository.purchaseItem(
      itemId: itemId,
      cost: cost,
      type: type,
    );
  }
}
