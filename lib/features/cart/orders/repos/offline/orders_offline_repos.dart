import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../../core/data/sqLite/database_service.dart';
import '../../../../../core/error/offline_error.dart';
import '../../../../../services_locator/service_locator.dart';
import '../../../../create_order/model/create_order_line_model.dart';
import '../../model/order_line_model.dart';
import '../../model/order_model.dart';
import '../../model/order_for_cart_edit_model.dart';
import '../../model/order_type_model.dart';
import 'orders_schema.dart';
import '../../../../customers/model/customer_address_row.dart';
import '../../../../payment_methods/model/payment_method_model.dart';
import '../../../../users/model/user_model.dart';
import '../../../../customers/repos/offline/customers_schema.dart';
import '../../../../payment_methods/repos/offline/payment_methods_schema.dart';
import '../../../../users/repos/offline/users_schema.dart';

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

  /// Loads a single order by id with its lines and resolves related entities
  /// needed to prefill the Cart in edit mode.
  Future<Either<OfflineFailure, OrderForCartEditModel>> getOrderForCartEdit(
    int orderId,
  );

  /// Updates an existing order record (keeps the same order id).
  Future<Either<OfflineFailure, int>> updateOrder(OrderModel order);

  /// Replaces the stored order lines for an order id.
  Future<Either<OfflineFailure, void>> updateOrderLines(
    int orderId,
    List<CreateOrderLineModel> lines,
  );

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
  Future<Either<OfflineFailure, OrderForCartEditModel>> getOrderForCartEdit(
    int orderId,
  ) async {
    try {
      final result = await _db.query(
        OrdersSchema.tableOrders,
        where: '${OrdersSchema.colId} = ?',
        whereArgs: [orderId],
      );

      if (result.isEmpty) {
        return Left(OfflineFailure.invalidArgument('Order not found'));
      }

      final row = result.first;
      final items = await _getOrderLinesByOrderId(orderId);
      final order = OrderModel.fromMap(row, items: items);

      UserModel? waiterUser;
      if (order.waiterId != null) {
        final userRows = await _db.query(
          UsersSchema.tableUsers,
          where: '${UsersSchema.colId} = ?',
          whereArgs: [order.waiterId],
        );
        if (userRows.isNotEmpty) {
          waiterUser = UserModel.fromMap(userRows.first);
        }
      }

      CustomerAddressRow? selectedCustomer;
      if (order.addressId != null) {
        final sql =
            CustomerAddressesSchema.getCustomerAddressesSql(
          'WHERE a.${CustomerAddressesSchema.colId} = ?',
        );
        final addressRows = await _db.rawQuery(sql, [order.addressId]);
        if (addressRows.isNotEmpty) {
          selectedCustomer = CustomerAddressRow.fromMap(addressRows.first);
        }
      }

      PaymentMethodModel? paymentMethod;
      if (order.paymentMethodId != null) {
        final paymentRows = await _db.query(
          PaymentMethodsSchema.tablePaymentMethods,
          where: '${PaymentMethodsSchema.colId} = ?',
          whereArgs: [order.paymentMethodId],
        );
        if (paymentRows.isNotEmpty) {
          paymentMethod = PaymentMethodModel.fromMap(paymentRows.first);
        }
      }

      paymentMethod ??= const PaymentMethodModel(
        id: null,
        vendorId: null,
        name: 'Cash',
        createdBy: null,
        createdAt: null,
        updatedAt: null,
      );

      return Right(
        OrderForCartEditModel(
          order: order,
          waiterUser: waiterUser,
          customerAddress: selectedCustomer,
          paymentMethod: paymentMethod,
        ),
      );
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.queryFailed(e),
      );
    }
  }

  @override
  Future<Either<OfflineFailure, int>> updateOrder(OrderModel order) async {
    try {
      if (order.id == null) {
        return Left(OfflineFailure.invalidArgument('Order id is required'));
      }

      final orderMap = order.toInsertMap();
      final count = await _db.update(
        OrdersSchema.tableOrders,
        orderMap,
        where: '${OrdersSchema.colId} = ?',
        whereArgs: [order.id],
      );
      return Right(count);
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.updateFailed(e),
      );
    }
  }

  @override
  Future<Either<OfflineFailure, void>> updateOrderLines(
    int orderId,
    List<CreateOrderLineModel> lines,
  ) async {
    try {
      // Ensure we replace the full line set (order_lines has no stable unique key).
      await _db.delete(
        OrderLinesSchema.tableOrderLines,
        where: '${OrderLinesSchema.colOrderId} = ?',
        whereArgs: [orderId],
      );
      return await insertOrderLines(orderId, lines);
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.deleteFailed(e),
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
