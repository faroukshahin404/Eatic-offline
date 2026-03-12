/// Variant info for a product when creating an order (id, base price, variable labels, all prices).
class CreateOrderVariantModel {
  const CreateOrderVariantModel({
    required this.id,
    required this.productId,
    required this.basePrice,
    this.isActive = true,
    this.sortOrder = 0,
    this.variableLabels = const [],
    this.valueIds = const [],
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
  /// Variable value IDs for this variant, in variable sort order (used to match user selection).
  final List<int> valueIds;
  /// Price list id -> price for this variant.
  final Map<int, double> priceListPrices;
  /// Addon id -> price for this variant.
  final Map<int, double> addonPrices;
}

/// One selectable option under a variant variable (e.g. "Large", "Medium").
class CreateOrderVariableOption {
  const CreateOrderVariableOption({
    required this.valueId,
    required this.label,
    this.priceModifier,
  });

  final int valueId;
  final String label;
  /// Optional extra price for this option (e.g. +75); may be null if not applicable.
  final double? priceModifier;
}

/// A variant variable with its options (e.g. "Size" with [Large, Medium, Small]).
class CreateOrderVariableGroup {
  const CreateOrderVariableGroup({
    required this.variableId,
    required this.name,
    this.sortOrder = 0,
    this.options = const [],
  });

  final int variableId;
  final String name;
  final int sortOrder;
  final List<CreateOrderVariableOption> options;
}
