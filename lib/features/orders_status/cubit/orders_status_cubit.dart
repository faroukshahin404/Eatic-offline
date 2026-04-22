import 'package:flutter_bloc/flutter_bloc.dart';

import '../../restaurant_tables/model/restaurant_table_model.dart';
import '../../restaurant_tables/repos/offline/restaurant_tables_offline_repos.dart';
import '../model/order_status_row_model.dart';
import '../repos/offline/orders_status_offline_repos.dart';

part 'orders_status_state.dart';

class OrdersStatusCubit extends Cubit<OrdersStatusState> {
  OrdersStatusCubit(this._repo, this._tablesRepo)
    : super(OrdersStatusInitial());

  final OrdersStatusOfflineRepository _repo;
  final RestaurantTablesOfflineRepository _tablesRepo;

  List<OrderStatusRowModel> orders = [];
  List<RestaurantTableModel> tables = [];

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

  Future<void> loadTables() async {
    emit(OrdersStatusLoading());
    final tablesResult = await _tablesRepo.getAll();
    final list = tablesResult.fold<List<RestaurantTableModel>>((f) {
      emit(OrdersStatusError(message: f.failureMessage ?? 'Error'));
      return const [];
    }, (tables) => tables);
    if (list.isEmpty && state is OrdersStatusError) return;

    final occupiedResult = await _repo.getTableIdsWithUnprintedOrders();
    occupiedResult.fold(
      (f) => emit(OrdersStatusError(message: f.failureMessage ?? 'Error')),
      (occupiedIds) {
        final occupiedSet = occupiedIds.toSet();
        tables =
            list.map((table) {
              final tableId = table.id;
              if (tableId == null) {
                return table.copyWith(isEmpty: 1);
              }
              return table.copyWith(
                isEmpty: occupiedSet.contains(tableId) ? 0 : 1,
              );
            }).toList();
        emit(OrdersStatusLoaded());
      },
    );
  }

  /// Returns the pending order ID linked to [tableId], or null if none.
  Future<int?> getPendingOrderIdByTableId(int tableId) async {
    final result = await _repo.getPendingOrderIdByTableId(tableId);
    return result.fold((_) => null, (id) => id);
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
