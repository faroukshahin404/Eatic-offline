import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/flutter_secure_storage.dart';
import '../../create_order/model/create_order_line_model.dart';
import '../../customers/model/customer_address_row.dart';
import '../../custody/repos/offline/custody_offline_repos.dart';
import '../../payment_methods/model/payment_method_model.dart';
import '../../payment_methods/repos/offline/payment_methods_offline_repos.dart';
import '../orders/model/order_model.dart';
import '../orders/repos/offline/orders_offline_repos.dart';
import '../../restaurant_tables/repos/offline/restaurant_tables_offline_repos.dart';
import '../../users/model/user_model.dart';
import 'cart_state.dart';

/// Fallback payment method when list is empty or load fails. id is null (saved as null = Cash on order).
const PaymentMethodModel _cashFallback = PaymentMethodModel(
  id: null,
  vendorId: null,
  name: 'Cash',
  createdBy: null,
  createdAt: null,
  updatedAt: null,
);

class CartCubit extends Cubit<CartState> {
  CartCubit(
    this.custodyRepo,
    this.ordersRepo,
    this.paymentMethodsRepo,
    this.restaurantTablesRepo,
  ) : super(const CartState());

  final CustodyOfflineRepository custodyRepo;
  final OrdersOfflineRepository ordersRepo;
  final PaymentMethodsOfflineRepository paymentMethodsRepo;
  final RestaurantTablesOfflineRepository restaurantTablesRepo;

  /// Reads stored user from secure storage (logged-in cashier). Returns null if not found or invalid.
  Future<UserModel?> _getStoredUser() async {
    try {
      final userJson = await SecureLocalStorageService.readSecureData('user');
      if (userJson.isEmpty) return null;
      final decoded = jsonDecode(userJson);
      if (decoded is! Map<String, dynamic>) return null;
      return UserModel.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  /// Computes discount amount from cart discount state and subtotal.
  static double _computeDiscountValue(CartState state, double subtotal) {
    switch (state.selectedDiscountType) {
      case CartDiscountType.amount:
        return (state.discountAmount ?? 0).clamp(0.0, subtotal);
      case CartDiscountType.percentage:
        final pct = state.discountPercentage ?? 0;
        if (pct <= 0 || pct > 100) return 0;
        return subtotal * (pct / 100);
      case CartDiscountType.coupon:
        return 0;
      case null:
        return 0;
    }
  }

  void setWaiter(UserModel? user) {
    emit(state.copyWith(selectedWaiter: user, clearWaiter: user == null));
  }

  void setTableNumber(String? tableNumber) {
    emit(state.copyWith(tableNumber: tableNumber));
  }

  void setSelectedTableId(int? tableId) {
    emit(state.copyWith(selectedTableId: tableId));
  }

  void setSelectedCustomer(CustomerAddressRow? customer) {
    emit(
      state.copyWith(
        selectedCustomer: customer,
        clearSelectedCustomer: customer == null,
      ),
    );
  }

  void clearCart() {
    emit(state.copyWith(items: []));
  }

  void setOrderType(int index) {
    if (index < 0 || index > 2) return;
    emit(state.copyWith(selectedOrderTypeIndex: index));
  }

  void addItem(CreateOrderLineModel line) {
    emit(state.copyWith(items: [...state.items, line]));
  }

  void incrementQuantity(int index) {
    if (index < 0 || index >= state.items.length) return;
    final line = state.items[index];
    final updated = line.copyWith(quantity: line.quantity + 1);
    final newItems = List<CreateOrderLineModel>.from(state.items)
      ..[index] = updated;
    emit(state.copyWith(items: newItems));
  }

  void decrementQuantity(int index) {
    if (index < 0 || index >= state.items.length) return;
    final line = state.items[index];
    if (line.quantity <= 1) {
      final newItems = List<CreateOrderLineModel>.from(state.items)
        ..removeAt(index);
      emit(state.copyWith(items: newItems));
      return;
    }
    final updated = line.copyWith(quantity: line.quantity - 1);
    final newItems = List<CreateOrderLineModel>.from(state.items)
      ..[index] = updated;
    emit(state.copyWith(items: newItems));
  }

  void setSelectedPaymentMethod(PaymentMethodModel? value) {
    emit(state.copyWith(selectedPaymentMethod: value));
  }

  /// Loads payment methods from repo. On empty or failure, uses Cash fallback so UI and order always have a value.
  Future<void> loadPaymentMethods() async {
    final result = await paymentMethodsRepo.getAll();
    result.fold(
      (_) {
        emit(state.copyWith(
          paymentMethods: [_cashFallback],
          selectedPaymentMethod: state.selectedPaymentMethod ?? _cashFallback,
        ));
      },
      (list) {
        final effectiveList = list.isEmpty ? [_cashFallback] : list;
        final current = state.selectedPaymentMethod;
        final selected = current != null &&
                effectiveList.any((p) => p.id != null && p.id == current.id)
            ? current
            : effectiveList.first;
        emit(state.copyWith(
          paymentMethods: effectiveList,
          selectedPaymentMethod: selected,
        ));
      },
    );
  }

  /// Refreshes [hasOpenCustody] from [CustodyOfflineRepository.getLastOpenCustody]. Call after cart is shown or after open/close custody dialogs complete.
  Future<void> refreshHasOpenCustody() async {
    final result = await custodyRepo.getLastOpenCustody();
    final hasOpen = result.fold((_) => false, (v) => v != null);
    emit(state.copyWith(hasOpenCustody: hasOpen));
  }

  void setDiscountByAmount(double? value) {
    emit(
      state.copyWith(
        selectedDiscountType: CartDiscountType.amount,
        discountAmount: value,
        discountPercentage: null,
        discountCouponCode: null,
      ),
    );
  }

  void setDiscountByPercentage(double? value) {
    emit(
      state.copyWith(
        selectedDiscountType: CartDiscountType.percentage,
        discountPercentage: value,
        discountAmount: null,
        discountCouponCode: null,
      ),
    );
  }

  // Coupon discount temporarily disabled.
  // void setDiscountByCoupon(String? code) {
  //   emit(state.copyWith(
  //     selectedDiscountType: CartDiscountType.coupon,
  //     discountCouponCode: code,
  //     discountAmount: null,
  //     discountPercentage: null,
  //   ));
  // }

  void clearDiscount() {
    emit(state.copyWith(clearDiscount: true));
  }

  /// Submits the cart as an order: saves order + lines, optional customer/table/waiter, and marks table occupied for dine-in.
  /// Requires: items not empty, logged-in user (cashier), open custody. For dine-in also requires waiter and table.
  /// Emits [isSubmitting] during run and [submitError] on failure; on success clears cart and [submitError].
  Future<void> submitOrder() async {
    emit(state.copyWith(isSubmitting: true, clearSubmitError: true));

    if (state.items.isEmpty) {
      emit(state.copyWith(
        isSubmitting: false,
        submitError: 'Cart is empty',
      ));
      return;
    }

    final cashier = await _getStoredUser();
    if (cashier == null || cashier.id == null) {
      emit(state.copyWith(
        isSubmitting: false,
        submitError: 'No logged-in user. Please log in as cashier.',
      ));
      return;
    }

    final custodyResult = await custodyRepo.getLastOpenCustody();
    final custody = custodyResult.fold((_) => null, (c) => c);
    if (custody == null || custody.id == null) {
      emit(state.copyWith(
        isSubmitting: false,
        submitError: 'No open custody. Please open a custody first.',
      ));
      return;
    }

    const orderTypeDineIn = 0;
    if (state.selectedOrderTypeIndex == orderTypeDineIn) {
      if (state.selectedWaiter == null || state.selectedWaiter!.id == null) {
        emit(state.copyWith(
          isSubmitting: false,
          submitError: 'Please select a waiter for dine-in orders.',
        ));
        return;
      }
      if (state.selectedTableId == null) {
        emit(state.copyWith(
          isSubmitting: false,
          submitError: 'Please select a table for dine-in orders.',
        ));
        return;
      }
    }

    final subtotal = state.items.fold<double>(
      0,
      (sum, line) => sum + line.lineTotal,
    );
    final discountValue = _computeDiscountValue(state, subtotal);
    final total = (subtotal - discountValue).clamp(0.0, double.infinity);

    final order = OrderModel(
      custodyId: custody.id!,
      cashierId: cashier.id!,
      orderType: state.selectedOrderTypeIndex,
      tableId: state.selectedOrderTypeIndex == orderTypeDineIn
          ? state.selectedTableId
          : null,
      tableNumber: state.selectedOrderTypeIndex == orderTypeDineIn
          ? state.tableNumber
          : null,
      waiterId: state.selectedOrderTypeIndex == orderTypeDineIn
          ? state.selectedWaiter!.id
          : null,
      customerId: state.selectedCustomer?.customerId,
      addressId: state.selectedCustomer?.addressId,
      paymentMethodId: state.selectedPaymentMethod?.id,
      subtotal: subtotal,
      discountAmount: discountValue,
      total: total,
    );

    final orderResult = await ordersRepo.insertOrder(order);
    final orderId = orderResult.fold<int?>(
      (failure) {
        emit(state.copyWith(
          isSubmitting: false,
          submitError: failure.failureMessage ?? 'Failed to save order',
        ));
        return null;
      },
      (id) => id,
    );
    if (orderId == null) return;

    final linesResult = await ordersRepo.insertOrderLines(orderId, state.items);
    final linesOk = linesResult.fold<bool>(
      (failure) {
        emit(state.copyWith(
          isSubmitting: false,
          submitError: failure.failureMessage ?? 'Failed to save order lines',
        ));
        return false;
      },
      (_) => true,
    );
    if (!linesOk) return;

    if (state.selectedOrderTypeIndex == orderTypeDineIn &&
        state.selectedTableId != null) {
      final tableResult = await restaurantTablesRepo.updateTableIsEmpty(
        state.selectedTableId!,
        0,
      );
          tableResult.fold(
            (failure) {
              emit(state.copyWith(
                isSubmitting: false,
                submitError: failure.failureMessage ??
                    'Order saved but failed to update table status',
              ));
            },
            (_) {
              emit(state.copyWith(
                items: [],
                isSubmitting: false,
                clearSubmitError: true,
                submitSuccess: true,
              ));
            },
          );
    } else {
      emit(state.copyWith(
        items: [],
        isSubmitting: false,
        clearSubmitError: true,
        submitSuccess: true,
      ));
    }
  }

  /// Clears the one-shot [submitSuccess] flag after UI has shown feedback.
  void clearSubmitSuccess() {
    emit(state.copyWith(clearSubmitSuccess: true));
  }
}
