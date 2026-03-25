import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../../core/data/sqLite/database_service.dart';
import '../../../../../core/error/offline_error.dart';
import '../../../../../services_locator/service_locator.dart';
import '../../../../create_order/model/create_order_line_model.dart';
import '../../model/order_line_model.dart';
import '../../model/order_model.dart';
import '../../model/order_type_model.dart';
import 'orders_schema.dart';

abstract class OrdersOfflineRepository {
  /// Inserts an order and returns its id.
  Future<Either<OfflineFailure, int>> insertOrder(OrderModel order);

  /// Inserts order lines for the given order id.
  Future<Either<OfflineFailure, void>> insertOrderLines(
    int orderId,
    List<CreateOrderLineModel> lines,
  );

  Future<Either<OfflineFailure, List<OrderModel>>> getOrdersByFilters({
    required int custodyId,
    required int selectedPriceListId,
    required int orderType,
    required int paymentMethodId,
  });

  Future<Either<OfflineFailure, List<OrderTypeModel>>> getOrderTypes();
}

class OrdersOfflineRepoImpl implements OrdersOfflineRepository {
  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, int>> insertOrder(OrderModel order) async {
    try {
      final orderMap = order.toInsertMap();
      // Any newly submitted order should be stored as pending for offline flows.
      orderMap[OrdersSchema.colIsPending] = 1;
      // Newly submitted orders are not printed yet.
      orderMap[OrdersSchema.colIsPrintedToCustomer] = 0;
      orderMap[OrdersSchema.colIsPrintedToKitchen] = 0;
      log(orderMap.toString());
      final id = await _db.insert(
        OrdersSchema.tableOrders,
        orderMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return Right(id);
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.insertFailed(e),
      );
    }
  }

  @override
  Future<Either<OfflineFailure, void>> insertOrderLines(
    int orderId,
    List<CreateOrderLineModel> lines,
  ) async {
    if (lines.isEmpty) return const Right(null);
    try {
      for (final line in lines) {
        final model = OrderLineModel(
          orderId: orderId,
          productId: line.productId,
          productName: line.productName,
          variantId: line.variantId,
          variantLabel: line.variantLabel,
          priceListId: line.priceListId,
          unitPrice: line.variantUnitPrice ?? 0,
          quantity: line.quantity,
          addonsTotal: line.addonsTotal,
          lineTotal: line.lineTotal,
          notes: line.notes.isEmpty ? null : line.notes,
        );
        await _db.insert(
          OrderLinesSchema.tableOrderLines,
          model.toInsertMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      return const Right(null);
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.insertFailed(e),
      );
    }
  }

  @override
  Future<Either<OfflineFailure, List<OrderModel>>> getOrdersByFilters({
    required int custodyId,
    required int selectedPriceListId,
    required int orderType,
    required int paymentMethodId,
  }) async {
    try {
      final result = await _db.query(
        OrdersSchema.tableOrders,
        where:
            '${OrdersSchema.colCustodyId} = ? AND '
            '${OrdersSchema.colSelectedPriceListId} = ? AND '
            '${OrdersSchema.colOrderType} = ? AND '
            '${OrdersSchema.colPaymentMethodId} = ?',
        whereArgs: [custodyId, selectedPriceListId, orderType, paymentMethodId],
        orderBy: '${OrdersSchema.colId} DESC',
      );

      final orders = <OrderModel>[];

      for (final row in result) {
        final orderId = row[OrdersSchema.colId] as int;
        final items = await _getOrderLinesByOrderId(orderId);
        orders.add(OrderModel.fromMap(row, items: items));
      }

      return Right(orders);
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.insertFailed(e),
      );
    }
  }

  Future<List<OrderLineModel>> _getOrderLinesByOrderId(int orderId) async {
    final result = await _db.query(
      OrderLinesSchema.tableOrderLines,
      where: '${OrderLinesSchema.colOrderId} = ?',
      whereArgs: [orderId],
      orderBy: OrderLinesSchema.colId,
    );

    return result.map(OrderLineModel.fromMap).toList();
  }

  @override
  Future<Either<OfflineFailure, List<OrderTypeModel>>> getOrderTypes() async {
    try {
      final result = await _db.query(OrderTypesSchema.tableOrderTypes);
      return Right(result.map(OrderTypeModel.fromMap).toList());
    } catch (e) {
      return Left(OfflineFailure.queryFailed(e));
    }
  }
}
