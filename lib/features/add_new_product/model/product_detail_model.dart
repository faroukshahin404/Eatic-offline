import 'add_product_input.dart';
import 'product_variable_row.dart';
import 'variant_prices_row.dart';

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
