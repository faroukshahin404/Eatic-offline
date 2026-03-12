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
