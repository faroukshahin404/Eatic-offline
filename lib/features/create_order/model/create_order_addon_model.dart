/// Addon info for a product when creating an order (addon id, name, price for this product).
class CreateOrderAddonModel {
  const CreateOrderAddonModel({
    required this.addonId,
    required this.name,
    this.price = 0.0,
  });

  final int addonId;
  final String name;
  final double price;
}
