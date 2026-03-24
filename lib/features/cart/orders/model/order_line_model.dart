import '../repos/offline/orders_schema.dart';

/// Order line entity for persistence (one row per product line in an order).
class OrderLineModel {
  const OrderLineModel({
    this.id,
    required this.orderId,
    required this.productId,
    this.productName,
    this.variantId,
    this.variantLabel,
    this.priceListId,
    this.unitPrice = 0,
    this.quantity = 1,
    this.addonsTotal = 0,
    this.lineTotal = 0,
    this.notes,
  });

  final int? id;
  final int orderId;
  final int productId;
  final String? productName;
  final int? variantId;
  final String? variantLabel;
  final int? priceListId;
  final double unitPrice;
  final int quantity;
  final double addonsTotal;
  final double lineTotal;
  final String? notes;

  Map<String, dynamic> toInsertMap() {
    return {
      OrderLinesSchema.colOrderId: orderId,
      OrderLinesSchema.colProductId: productId,
      OrderLinesSchema.colProductName: productName,
      OrderLinesSchema.colVariantId: variantId,
      OrderLinesSchema.colVariantLabel: variantLabel,
      OrderLinesSchema.colPriceListId: priceListId,
      OrderLinesSchema.colUnitPrice: unitPrice,
      OrderLinesSchema.colQuantity: quantity,
      OrderLinesSchema.colAddonsTotal: addonsTotal,
      OrderLinesSchema.colLineTotal: lineTotal,
      OrderLinesSchema.colNotes: notes,
    };
  }
  factory OrderLineModel.fromMap(Map<String, dynamic> map) {
  return OrderLineModel(
    id: map[OrderLinesSchema.colId] as int?,
    orderId: map[OrderLinesSchema.colOrderId] as int,
    productId: map[OrderLinesSchema.colProductId] as int,
    productName: map[OrderLinesSchema.colProductName] as String?,
    variantId: map[OrderLinesSchema.colVariantId] as int?,
    variantLabel: map[OrderLinesSchema.colVariantLabel] as String?,
    priceListId: map[OrderLinesSchema.colPriceListId] as int?,
    unitPrice: (map[OrderLinesSchema.colUnitPrice] as num?)?.toDouble() ?? 0,
    quantity: map[OrderLinesSchema.colQuantity] as int? ?? 1,
    addonsTotal: (map[OrderLinesSchema.colAddonsTotal] as num?)?.toDouble() ?? 0,
    lineTotal: (map[OrderLinesSchema.colLineTotal] as num?)?.toDouble() ?? 0,
    notes: map[OrderLinesSchema.colNotes] as String?,
  );
}
}
