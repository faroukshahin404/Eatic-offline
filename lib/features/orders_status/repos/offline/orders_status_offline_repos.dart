import 'package:dartz/dartz.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../../cart/orders/repos/offline/orders_schema.dart';
import '../../../customers/repos/offline/customers_schema.dart';
import '../../../payment_methods/repos/offline/payment_methods_schema.dart';
import '../../../restaurant_tables/repos/offline/restaurant_tables_schema.dart';
import '../../../users/repos/offline/users_schema.dart';
import '../../model/order_status_row_model.dart';

abstract class OrdersStatusOfflineRepository {
  DbCall<List<OrderStatusRowModel>> getPendingOrders();

  /// Returns the order ID of the pending order linked to [tableId], or null.
  DbCall<int?> getPendingOrderIdByTableId(int tableId);

  Future<Either<OfflineFailure, int>> updatePrintedStatus({
    required int orderId,
    required int isPrintedToCustomer,
    required int isPrintedToKitchen,
  });
}

class OrdersStatusOfflineRepoImpl implements OrdersStatusOfflineRepository {
  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, List<OrderStatusRowModel>>>
      getPendingOrders() async {
    try {
      final rows = await _db.query(
        OrdersSchema.tableOrders,
        where: '${OrdersSchema.colIsPending} = ?',
        whereArgs: [1],
        orderBy: '${OrdersSchema.colId} DESC',
      );

      final results = <OrderStatusRowModel>[];

      for (final row in rows) {
        final rowMap = Map<String, dynamic>.from(row);

        // Resolve order type.
        final orderTypeId = (rowMap[OrdersSchema.colOrderType] as num?)
            ?.toInt();
        if (orderTypeId != null) {
          final typeRows = await _db.query(
            OrderTypesSchema.tableOrderTypes,
            where: '${OrderTypesSchema.colId} = ?',
            whereArgs: [orderTypeId],
          );
          if (typeRows.isNotEmpty) {
            rowMap['order_type'] = typeRows.first;
          }
        }

        // Resolve cashier user.
        final cashierId =
            (rowMap[OrdersSchema.colCashierId] as num?)?.toInt();
        if (cashierId != null) {
          final userRows = await _db.query(
            UsersSchema.tableUsers,
            where: '${UsersSchema.colId} = ?',
            whereArgs: [cashierId],
          );
          if (userRows.isNotEmpty) {
            rowMap['cashier_user'] = userRows.first;
          }
        }

        // Resolve waiter user.
        final waiterId = (rowMap[OrdersSchema.colWaiterId] as num?)?.toInt();
        if (waiterId != null) {
          final userRows = await _db.query(
            UsersSchema.tableUsers,
            where: '${UsersSchema.colId} = ?',
            whereArgs: [waiterId],
          );
          if (userRows.isNotEmpty) {
            rowMap['waiter_user'] = userRows.first;
          }
        }

        // Resolve customer.
        final customerId =
            (rowMap[OrdersSchema.colCustomerId] as num?)?.toInt();
        if (customerId != null) {
          final customerRows = await _db.query(
            CustomersSchema.tableCustomers,
            where: '${CustomersSchema.colId} = ?',
            whereArgs: [customerId],
          );
          if (customerRows.isNotEmpty) {
            rowMap['customer'] = customerRows.first;
          }
        }

        // Resolve payment method.
        final paymentMethodId =
            (rowMap[OrdersSchema.colPaymentMethodId] as num?)?.toInt();
        if (paymentMethodId != null) {
          final paymentRows = await _db.query(
            PaymentMethodsSchema.tablePaymentMethods,
            where: '${PaymentMethodsSchema.colId} = ?',
            whereArgs: [paymentMethodId],
          );
          if (paymentRows.isNotEmpty) {
            rowMap['payment_method'] = paymentRows.first;
          }
        }

        results.add(OrderStatusRowModel.fromMap(rowMap));
      }

      return Right(results);
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.queryFailed(e),
      );
    }
  }

  @override
  Future<Either<OfflineFailure, int?>> getPendingOrderIdByTableId(
    int tableId,
  ) async {
    try {
      final rows = await _db.query(
        OrdersSchema.tableOrders,
        columns: [OrdersSchema.colId],
        where:
            '${OrdersSchema.colIsPending} = ? AND ${OrdersSchema.colTableId} = ?',
        whereArgs: [1, tableId],
        orderBy: '${OrdersSchema.colId} DESC',
        limit: 1,
      );
      if (rows.isEmpty) return const Right(null);
      return Right(rows.first[OrdersSchema.colId] as int);
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.queryFailed(e),
      );
    }
  }

  @override
  Future<Either<OfflineFailure, int>> updatePrintedStatus({
    required int orderId,
    required int isPrintedToCustomer,
    required int isPrintedToKitchen,
  }) async {
    try {
      final resultCount = await _db.transaction<int>((txn) async {
        final count = await txn.update(
          OrdersSchema.tableOrders,
          {
            OrdersSchema.colIsPrintedToCustomer: isPrintedToCustomer,
            OrdersSchema.colIsPrintedToKitchen: isPrintedToKitchen,
          },
          where: '${OrdersSchema.colId} = ?',
          whereArgs: [orderId],
        );

        // Business rule:
        // If order type is dine-in, mark its assigned table as available after printing.
        final orderRows = await txn.query(
          OrdersSchema.tableOrders,
          where: '${OrdersSchema.colId} = ?',
          whereArgs: [orderId],
          limit: 1,
        );

        if (orderRows.isNotEmpty) {
          final orderRow = orderRows.first;
          final orderType = (orderRow[OrdersSchema.colOrderType] as num?)
              ?.toInt();
          final tableId = (orderRow[OrdersSchema.colTableId] as num?)
              ?.toInt();

          // 0 = dine-in (see OrderModel comment).
          if (orderType == 0 && tableId != null) {
            await txn.update(
              RestaurantTablesSchema.tableRestaurantTables,
              {
                RestaurantTablesSchema.colIsEmpty: 1,
                RestaurantTablesSchema.colUpdatedAt:
                    DateTime.now().toIso8601String(),
              },
              where: '${RestaurantTablesSchema.colId} = ?',
              whereArgs: [tableId],
            );
          }
        }

        return count;
      });

      return Right(resultCount);
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.updateFailed(e),
      );
    }
  }
}

