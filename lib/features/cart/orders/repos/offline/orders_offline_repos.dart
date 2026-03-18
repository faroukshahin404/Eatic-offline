import 'package:dartz/dartz.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../../core/data/sqLite/database_service.dart';
import '../../../../../core/error/offline_error.dart';
import '../../../../../services_locator/service_locator.dart';
import '../../../../create_order/model/create_order_line_model.dart';
import '../../model/order_line_model.dart';
import '../../model/order_model.dart';
import 'orders_schema.dart';

abstract class OrdersOfflineRepository {
  /// Inserts an order and returns its id.
  Future<Either<OfflineFailure, int>> insertOrder(OrderModel order);

  /// Inserts order lines for the given order id.
  Future<Either<OfflineFailure, void>> insertOrderLines(
    int orderId,
    List<CreateOrderLineModel> lines,
  );
}

class OrdersOfflineRepoImpl implements OrdersOfflineRepository {
  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, int>> insertOrder(OrderModel order) async {
    try {
      final id = await _db.insert(
        OrdersSchema.tableOrders,
        order.toInsertMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return Right(id as int);
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
}
