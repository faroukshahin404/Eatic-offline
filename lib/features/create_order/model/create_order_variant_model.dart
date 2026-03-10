/// Variant info for a product when creating an order (id, base price, variable labels, all prices).
class CreateOrderVariantModel {
  const CreateOrderVariantModel({
    required this.id,
    required this.productId,
    required this.basePrice,
    this.isActive = true,
    this.sortOrder = 0,
    this.variableLabels = const [],
    this.priceListPrices = const {},
    this.addonPrices = const {},
  });

  final int id;
  final int productId;
  final double basePrice;
  final bool isActive;
  final int sortOrder;
  /// Display labels for this variant (e.g. ["Large", "Red"]).
  final List<String> variableLabels;
  /// Price list id -> price for this variant.
  final Map<int, double> priceListPrices;
  /// Addon id -> price for this variant.
  final Map<int, double> addonPrices;
}
