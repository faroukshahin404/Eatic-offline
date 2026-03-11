import '../../create_order/model/create_order_line_model.dart';

/// Cart state: items, order type, custody flag, and mock order info.
class CartState {
  const CartState({
    this.items = const [],
    this.selectedOrderTypeIndex = 0,
    this.hasOpenCustody = false,
    this.orderNumber = '#8712',
    this.tableNumber,
  });

  final List<CreateOrderLineModel> items;
  final int selectedOrderTypeIndex;
  final bool hasOpenCustody;
  final String orderNumber;
  final String? tableNumber;

  CartState copyWith({
    List<CreateOrderLineModel>? items,
    int? selectedOrderTypeIndex,
    bool? hasOpenCustody,
    String? orderNumber,
    String? tableNumber,
  }) {
    return CartState(
      items: items ?? this.items,
      selectedOrderTypeIndex:
          selectedOrderTypeIndex ?? this.selectedOrderTypeIndex,
      hasOpenCustody: hasOpenCustody ?? this.hasOpenCustody,
      orderNumber: orderNumber ?? this.orderNumber,
      tableNumber: tableNumber ?? this.tableNumber,
    );
  }
}
