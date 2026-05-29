import '../../../../core/utils/result.dart';

/// Contrato abstracto para el repositorio de la Tienda RPG.
/// Capa de Dominio (Domain Layer) - Define la transacción de compra.
abstract class StoreRepository {
  /// Realiza la compra de un artículo de la tienda.
  Future<Result<void>> purchaseItem({
    required String itemId,
    required int cost,
    required String type,
  });
}
