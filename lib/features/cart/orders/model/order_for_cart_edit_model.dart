import '../../../customers/model/customer_address_row.dart';
import '../../../payment_methods/model/payment_method_model.dart';
import '../../../users/model/user_model.dart';

import 'order_model.dart';

/// Enriched order data used to prefill the Cart in edit mode.
class OrderForCartEditModel {
  const OrderForCartEditModel({
    required this.order,
    this.waiterUser,
    this.customerAddress,
    this.paymentMethod,
  });

  final OrderModel order;

  /// Resolved waiter user (needed for dine-in submit validation).
  final UserModel? waiterUser;

  /// Resolved customer address row (needed for delivery/takeaway submit).
  final CustomerAddressRow? customerAddress;

  /// Resolved selected payment method (used as-is for submit).
  final PaymentMethodModel? paymentMethod;
}

