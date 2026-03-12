import '../../create_order/model/create_order_line_model.dart';
import '../../customers/model/customer_address_row.dart';
import '../../users/model/user_model.dart';

/// Discount type selected in the cart footer.
enum CartDiscountType { amount, percentage, coupon }

/// Cart state: items, order type, custody flag, selected waiter, selected customer, discount, and mock order info.
class CartState {
  const CartState({
    this.items = const [],
    this.selectedOrderTypeIndex = 0,
    this.hasOpenCustody = false,
    this.orderNumber = '#8712',
    this.tableNumber,
    this.selectedWaiter,
    this.selectedCustomer,
    this.selectedDiscountType,
    this.discountAmount,
    this.discountPercentage,
    this.discountCouponCode,
  });

  final List<CreateOrderLineModel> items;
  final int selectedOrderTypeIndex;
  final bool hasOpenCustody;
  final String orderNumber;
  final String? tableNumber;
  final UserModel? selectedWaiter;
  final CustomerAddressRow? selectedCustomer;
  final CartDiscountType? selectedDiscountType;
  final double? discountAmount;
  final double? discountPercentage;
  final String? discountCouponCode;

  CartState copyWith({
    List<CreateOrderLineModel>? items,
    int? selectedOrderTypeIndex,
    bool? hasOpenCustody,
    String? orderNumber,
    String? tableNumber,
    UserModel? selectedWaiter,
    bool clearWaiter = false,
    CustomerAddressRow? selectedCustomer,
    bool clearSelectedCustomer = false,
    CartDiscountType? selectedDiscountType,
    double? discountAmount,
    double? discountPercentage,
    String? discountCouponCode,
    bool clearDiscount = false,
  }) {
    return CartState(
      items: items ?? this.items,
      selectedOrderTypeIndex:
          selectedOrderTypeIndex ?? this.selectedOrderTypeIndex,
      hasOpenCustody: hasOpenCustody ?? this.hasOpenCustody,
      orderNumber: orderNumber ?? this.orderNumber,
      tableNumber: tableNumber ?? this.tableNumber,
      selectedWaiter: clearWaiter
          ? null
          : (selectedWaiter ?? this.selectedWaiter),
      selectedCustomer: clearSelectedCustomer
          ? null
          : (selectedCustomer ?? this.selectedCustomer),
      selectedDiscountType: clearDiscount
          ? null
          : (selectedDiscountType ?? this.selectedDiscountType),
      discountAmount: clearDiscount ? null : (discountAmount ?? this.discountAmount),
      discountPercentage: clearDiscount ? null : (discountPercentage ?? this.discountPercentage),
      discountCouponCode: clearDiscount ? null : (discountCouponCode ?? this.discountCouponCode),
    );
  }
}
