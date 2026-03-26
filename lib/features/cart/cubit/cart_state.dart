import 'package:Eatic/core/utils/app_utils.dart';

import '../../create_order/model/create_order_line_model.dart';
import '../../customers/model/customer_address_row.dart';
import '../../payment_methods/model/payment_method_model.dart';
import '../../users/model/user_model.dart';
import '../orders/model/order_type_model.dart';

/// Discount type selected in the cart footer.
enum CartDiscountType { amount, percentage, coupon }

/// Cart state: items, order type, custody flag, selected waiter, selected table, selected customer, discount, and mock order info.
class CartState {
  const CartState({
    this.items = const [],
    this.selectedOrderTypeIndex = 0,
    this.hasOpenCustody = false,
    this.isEditMode = false,
    this.editingOrderId,
    this.orderNumber = '#8712',
    this.tableNumber,
    this.selectedTableId,
    this.selectedWaiter,
    this.selectedCustomer,
    this.selectedDiscountType,
    this.discountAmount,
    this.discountPercentage,
    this.discountCouponCode,
    this.isSubmitting = false,
    this.submitError,
    this.submitSuccess = false,
    this.paymentMethods = const [],
    this.selectedPaymentMethod,
    this.orderTypes = const [],
    this.screenState,
  });

  final List<CreateOrderLineModel> items;
  final List<OrderTypeModel> orderTypes;
  final ScreenState? screenState;
  final int selectedOrderTypeIndex;
  final bool hasOpenCustody;
  final bool isEditMode;
  final int? editingOrderId;
  final String orderNumber;
  final String? tableNumber;
  /// Table id from restaurant_tables (used for dine-in order and marking table occupied).
  final int? selectedTableId;
  final UserModel? selectedWaiter;
  final CustomerAddressRow? selectedCustomer;
  final bool isSubmitting;
  final String? submitError;
  final bool submitSuccess;
  final List<PaymentMethodModel> paymentMethods;
  final PaymentMethodModel? selectedPaymentMethod;
  final CartDiscountType? selectedDiscountType;
  final double? discountAmount;
  final double? discountPercentage;
  final String? discountCouponCode;

  CartState copyWith({
    List<CreateOrderLineModel>? items,
    int? selectedOrderTypeIndex,
    ScreenState? screenState,
    bool? hasOpenCustody,
    bool? isEditMode,
    int? editingOrderId,
    bool clearEditMode = false,
    String? orderNumber,
    String? tableNumber,
    int? selectedTableId,
    UserModel? selectedWaiter,
    bool clearWaiter = false,
    CustomerAddressRow? selectedCustomer,
    bool clearSelectedCustomer = false,
    CartDiscountType? selectedDiscountType,
    double? discountAmount,
    double? discountPercentage,
    String? discountCouponCode,
    bool clearDiscount = false,
    bool? isSubmitting,
    String? submitError,
    bool clearSubmitError = false,
    bool? submitSuccess,
    bool clearSubmitSuccess = false,
    List<PaymentMethodModel>? paymentMethods,
    PaymentMethodModel? selectedPaymentMethod,
    bool clearSelectedPaymentMethod = false,
    List<OrderTypeModel>? orderTypes,
  }) {
    return CartState(
      screenState: screenState ?? this.screenState,
      orderTypes: orderTypes ?? this.orderTypes,
      items: items ?? this.items,
      selectedOrderTypeIndex:
          selectedOrderTypeIndex ?? this.selectedOrderTypeIndex,
      hasOpenCustody: hasOpenCustody ?? this.hasOpenCustody,
      isEditMode: clearEditMode ? false : (isEditMode ?? this.isEditMode),
      editingOrderId:
          clearEditMode ? null : (editingOrderId ?? this.editingOrderId),
      orderNumber: orderNumber ?? this.orderNumber,
      tableNumber: tableNumber ?? this.tableNumber,
      selectedTableId: selectedTableId ?? this.selectedTableId,
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
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      submitSuccess: clearSubmitSuccess ? false : (submitSuccess ?? this.submitSuccess),
      paymentMethods: paymentMethods ?? this.paymentMethods,
      selectedPaymentMethod: clearSelectedPaymentMethod
          ? null
          : (selectedPaymentMethod ?? this.selectedPaymentMethod),
    );
  }
}
