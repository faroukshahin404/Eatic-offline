import 'package:flutter_bloc/flutter_bloc.dart';

import '../../create_order/model/create_order_line_model.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());

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

  void setHasOpenCustody(bool value) {
    emit(state.copyWith(hasOpenCustody: value));
  }
}
