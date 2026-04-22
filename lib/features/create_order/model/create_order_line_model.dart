/// One selected variant option (variable + chosen value) for display in cart/card.
class SelectedVariantOption {
  const SelectedVariantOption({
    required this.variableId,
    required this.variableName,
    required this.valueId,
    required this.valueLabel,
  });

  final int variableId;
  final String variableName;
  final int valueId;
  final String valueLabel;
}

/// Selected addon details for receipt and cart display.
class SelectedAddonOption {
  const SelectedAddonOption({
    required this.addonId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  final int addonId;
  final String name;
  final int quantity;
  final double unitPrice;

  double get total => unitPrice * quantity;
}

/// Full order line data for a single product configuration, ready for cart/order usage.
class CreateOrderLineModel {
  const CreateOrderLineModel({
    required this.productId,
    this.productName,
    this.variantId,
    this.variantLabel,
    this.selectedOptions = const [],
    this.selectedAddons = const [],
    this.notes = '',
    this.quantity = 1,
    this.priceListId,
    this.variantUnitPrice,
    this.addonQuantities = const {},
    this.addonsTotal = 0,
    this.lineTotal = 0,
  });

  /// Product identifier.
  final int productId;

  /// Product name for display (e.g. in cart).
  final String? productName;

  /// Selected variant id (null if product has no variants or legacy flow).
  final int? variantId;

  /// Human-readable variant label (e.g. "Large, Hot").
  final String? variantLabel;

  /// Selected option per variable (for cart rendering and persistence).
  final List<SelectedVariantOption> selectedOptions;

  /// Selected addons with names and prices (used for receipt printing).
  final List<SelectedAddonOption> selectedAddons;

  /// Customer notes for this line.
  final String notes;

  /// Line quantity (default 1).
  final int quantity;

  /// Price list used for variant unit price.
  final int? priceListId;

  /// Variant unit price (from selected price list or base).
  final double? variantUnitPrice;

  /// Addon id -> quantity.
  final Map<int, int> addonQuantities;

  /// Sum of (addon unit price * quantity) for this line.
  final double addonsTotal;

  /// Grand total: (variantUnitPrice * quantity) + addonsTotal (or equivalent).
  final double lineTotal;

  CreateOrderLineModel copyWith({
    int? productId,
    String? productName,
    int? variantId,
    String? variantLabel,
    List<SelectedVariantOption>? selectedOptions,
    List<SelectedAddonOption>? selectedAddons,
    String? notes,
    int? quantity,
    int? priceListId,
    double? variantUnitPrice,
    Map<int, int>? addonQuantities,
    double? addonsTotal,
    double? lineTotal,
  }) {
    final q = quantity ?? this.quantity;
    final unit = variantUnitPrice ?? this.variantUnitPrice ?? 0;
    final addons = addonsTotal ?? this.addonsTotal;
    return CreateOrderLineModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      variantId: variantId ?? this.variantId,
      variantLabel: variantLabel ?? this.variantLabel,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      selectedAddons: selectedAddons ?? this.selectedAddons,
      notes: notes ?? this.notes,
      quantity: q,
      priceListId: priceListId ?? this.priceListId,
      variantUnitPrice: variantUnitPrice ?? this.variantUnitPrice,
      addonQuantities: addonQuantities ?? this.addonQuantities,
      addonsTotal: addons,
      lineTotal: lineTotal ?? (unit * q + addons),
    );
  }
}
