import '../../cart/orders/model/order_type_model.dart';
import '../../cart/orders/repos/offline/orders_schema.dart';
import '../../users/model/user_model.dart';
import '../../customers/repos/offline/customers_schema.dart';
import '../../payment_methods/model/payment_method_model.dart';

/// Row model for the Orders Status table UI.
class OrderStatusRowModel {
  const OrderStatusRowModel({
    required this.id,
    required this.total,
    required this.orderTypeName,
    required this.paymentMethodName,
    required this.cashierName,
    required this.customerName,
    this.tableNumber,
    this.waiterName,
    required this.isPrintedToCustomer,
    required this.isPrintedToKitchen,
    required this.createdAt,
  });

  final int id;
  final double total;
  final String orderTypeName;
  final String paymentMethodName;
  final String cashierName;
  final String customerName;
  final String? tableNumber;
  final String? waiterName;
  final int isPrintedToCustomer;
  final int isPrintedToKitchen;
  final String? createdAt;

  factory OrderStatusRowModel.fromMap(Map<String, dynamic> map) {
    final orderTypeData = map['order_type'] as Map<String, dynamic>?;
    final orderType = orderTypeData == null
        ? null
        : OrderTypeModel.fromMap(orderTypeData);

    final cashierData = map['cashier_user'] as Map<String, dynamic>?;
    final cashierUser = cashierData == null ? null : UserModel.fromMap(cashierData);

    final waiterData = map['waiter_user'] as Map<String, dynamic>?;
    final waiterUser = waiterData == null ? null : UserModel.fromMap(waiterData);

    final customerData = map['customer'] as Map<String, dynamic>?;
    final customerName = customerData == null
        ? null
        : (customerData[CustomersSchema.colName] as String?);

    final paymentMethodData =
        map['payment_method'] as Map<String, dynamic>?;
    final paymentMethod = paymentMethodData == null
        ? null
        : PaymentMethodModel.fromMap(paymentMethodData);

    return OrderStatusRowModel(
      id: map[OrdersSchema.colId] as int,
      total: (map[OrdersSchema.colTotal] as num?)?.toDouble() ?? 0,
      orderTypeName: orderType?.name ?? '-',
      paymentMethodName: paymentMethod?.name ?? '-',
      cashierName: cashierUser?.name ?? cashierUser?.code ?? '-',
      customerName: customerName ?? '-',
      tableNumber: map[OrdersSchema.colTableNumber] as String?,
      waiterName: waiterUser?.name ?? waiterUser?.code,
      isPrintedToCustomer:
          (map[OrdersSchema.colIsPrintedToCustomer] as int?) ?? 0,
      isPrintedToKitchen:
          (map[OrdersSchema.colIsPrintedToKitchen] as int?) ?? 0,
      createdAt: map[OrdersSchema.colCreatedAt] as String?,
    );
  }
}

