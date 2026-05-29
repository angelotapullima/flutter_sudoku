/// Entidad de negocio pura e inmutable que representa un artículo comprable en la tienda RPG.
/// Capa de Dominio (Domain Layer) - Pura y sin dependencias externas.
class StoreItem {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int cost;
  final String type;

  const StoreItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.cost,
    required this.type,
  });
}
