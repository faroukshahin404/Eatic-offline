import '../repos/offline/orders_schema.dart';

/// Order entity for persistence. order_type: 0 = dine in, 1 = takeaway, 2 = delivery.
/// [paymentMethodId] null means Cash (fallback when no payment method selected or list empty).
class OrderModel {
  const OrderModel({
    this.id,
    required this.custodyId,
    required this.cashierId,
    required this.orderType,
    this.tableId,
    this.tableNumber,
    this.waiterId,
    this.customerId,
    this.addressId,
    this.paymentMethodId,
    this.subtotal = 0,
    this.discountAmount = 0,
    this.total = 0,
    this.createdAt,
  });

  final int? id;
  final int custodyId;
  final int cashierId;
  final int orderType;
  final int? tableId;
  final String? tableNumber;
  final int? waiterId;
  final int? customerId;
  final int? addressId;
  final int? paymentMethodId;
  final double subtotal;
  final double discountAmount;
  final double total;
  final String? createdAt;

  Map<String, dynamic> toInsertMap() {
    final now = DateTime.now().toIso8601String();
    return {
      OrdersSchema.colCustodyId: custodyId,
      OrdersSchema.colCashierId: cashierId,
      OrdersSchema.colOrderType: orderType,
      OrdersSchema.colTableId: tableId,
      OrdersSchema.colTableNumber: tableNumber,
      OrdersSchema.colWaiterId: waiterId,
      OrdersSchema.colCustomerId: customerId,
      OrdersSchema.colAddressId: addressId,
      OrdersSchema.colPaymentMethodId: paymentMethodId,
      OrdersSchema.colSubtotal: subtotal,
      OrdersSchema.colDiscountAmount: discountAmount,
      OrdersSchema.colTotal: total,
      OrdersSchema.colCreatedAt: createdAt ?? now,
    };
  }
}
