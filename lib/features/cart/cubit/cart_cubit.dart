import 'package:flutter_bloc/flutter_bloc.dart';

import '../../create_order/model/create_order_line_model.dart';
import '../../customers/model/customer_address_row.dart';
import '../../custody/repos/offline/custody_offline_repos.dart';
import '../../users/model/user_model.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit(this._custodyRepo) : super(const CartState());

  final CustodyOfflineRepository _custodyRepo;

  void setWaiter(UserModel? user) {
    emit(state.copyWith(selectedWaiter: user, clearWaiter: user == null));
  }

  void setTableNumber(String? tableNumber) {
    emit(state.copyWith(tableNumber: tableNumber));
  }

  void setSelectedCustomer(CustomerAddressRow? customer) {
    emit(state.copyWith(
      selectedCustomer: customer,
      clearSelectedCustomer: customer == null,
    ));
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

  /// Refreshes [hasOpenCustody] from [CustodyOfflineRepository.getLastOpenCustody]. Call after cart is shown or after open/close custody dialogs complete.
  Future<void> refreshHasOpenCustody() async {
    final result = await _custodyRepo.getLastOpenCustody();
    final hasOpen = result.fold((_) => false, (v) => v != null);
    emit(state.copyWith(hasOpenCustody: hasOpen));
  }

  void setDiscountByAmount(double? value) {
    emit(state.copyWith(
      selectedDiscountType: CartDiscountType.amount,
      discountAmount: value,
      discountPercentage: null,
      discountCouponCode: null,
    ));
  }

  void setDiscountByPercentage(double? value) {
    emit(state.copyWith(
      selectedDiscountType: CartDiscountType.percentage,
      discountPercentage: value,
      discountAmount: null,
      discountCouponCode: null,
    ));
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
}
