import 'product_variable_row.dart';
import 'variant_prices_row.dart';

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
