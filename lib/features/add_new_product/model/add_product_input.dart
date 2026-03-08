/// One variable row in the variants section: name (e.g. Size) + list of values (e.g. Large, Medium, Small).
class ProductVariableRow {
  ProductVariableRow({this.name = '', List<String>? values, int? id})
      : values = values ?? [''],
        id = id ?? _nextId++;

  static int _nextId = 0;

  final int id;
  String name;
  List<String> values;
}

/// Prices and active state for one variant row (order matches cartesian product of variable values).
class VariantPricesRow {
  VariantPricesRow({
    this.basePrice = 0,
    this.isActive = true,
    Map<int, double>? priceListPrices,
    Map<int, double>? addonPrices,
  })  : priceListPrices = priceListPrices ?? {},
        addonPrices = addonPrices ?? {};

  double basePrice;
  bool isActive;
  Map<int, double> priceListPrices; // price_list_id -> price
  Map<int, double> addonPrices;     // addon_id -> price
}

/// Input DTO for adding a new product (form data).
class AddProductInput {
  AddProductInput({
    required this.name,
    this.nameEn,
    this.description,
    List<int>? categoryIds,
    this.hasVariants = false,
    List<ProductVariableRow>? variableRows,
    List<int>? addonIds,
    Map<int, double>? productPriceListPrices,
    List<VariantPricesRow>? variantPricesRows,
  })  : categoryIds = categoryIds ?? [],
        variableRows = variableRows ?? [],
        addonIds = addonIds ?? [],
        productPriceListPrices = productPriceListPrices ?? {},
        variantPricesRows = variantPricesRows ?? [];

  final String name;
  final String? nameEn;
  final String? description;
  final List<int> categoryIds;
  final bool hasVariants;
  final List<ProductVariableRow> variableRows;
  final List<int> addonIds;
  /// Product-level price list prices (when no variants or default).
  final Map<int, double> productPriceListPrices;
  /// Per-variant prices (order = cartesian product of variable values).
  final List<VariantPricesRow> variantPricesRows;
}

/// Full product data for get-by-id and update (same shape as AddProductInput with id).
class ProductDetailModel {
  ProductDetailModel({
    required this.id,
    required this.name,
    this.nameEn,
    this.description,
    List<int>? categoryIds,
    this.hasVariants = false,
    List<ProductVariableRow>? variableRows,
    List<int>? addonIds,
    Map<int, double>? productPriceListPrices,
    List<VariantPricesRow>? variantPricesRows,
  })  : categoryIds = categoryIds ?? [],
        variableRows = variableRows ?? [],
        addonIds = addonIds ?? [],
        productPriceListPrices = productPriceListPrices ?? {},
        variantPricesRows = variantPricesRows ?? [];

  final int id;
  final String name;
  final String? nameEn;
  final String? description;
  final List<int> categoryIds;
  final bool hasVariants;
  final List<ProductVariableRow> variableRows;
  final List<int> addonIds;
  final Map<int, double> productPriceListPrices;
  final List<VariantPricesRow> variantPricesRows;

  AddProductInput toAddProductInput() {
    return AddProductInput(
      name: name,
      nameEn: nameEn,
      description: description,
      categoryIds: List.from(categoryIds),
      hasVariants: hasVariants,
      variableRows: variableRows,
      addonIds: List.from(addonIds),
      productPriceListPrices: Map.from(productPriceListPrices),
      variantPricesRows: variantPricesRows,
    );
  }
}
