import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/order_status_row_model.dart';
import '../repos/offline/orders_status_offline_repos.dart';

part 'orders_status_state.dart';

class OrdersStatusCubit extends Cubit<OrdersStatusState> {
  OrdersStatusCubit(this._repo) : super(OrdersStatusInitial());

  final OrdersStatusOfflineRepository _repo;

  List<OrderStatusRowModel> orders = [];

  Future<void> loadPendingOrders() async {
    emit(OrdersStatusLoading());
    final result = await _repo.getPendingOrders();
    result.fold(
      (f) => emit(OrdersStatusError(message: f.failureMessage ?? 'Error')),
      (orders) {
        this.orders = orders;
        emit(OrdersStatusLoaded());
      },
    );
  }

  Future<void> updatePrintedStatus({
    required int orderId,
    required int isPrintedToCustomer,
    required int isPrintedToKitchen,
  }) async {
    final result = await _repo.updatePrintedStatus(
      orderId: orderId,
      isPrintedToCustomer: isPrintedToCustomer,
      isPrintedToKitchen: isPrintedToKitchen,
    );

    result.fold(
      (f) => emit(OrdersStatusError(message: f.failureMessage ?? 'Error')),
      (_) => loadPendingOrders(),
    );
  }
}

