import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../../zones/repos/offline/zones_schema.dart';
import '../../model/customer_address_row.dart';
import 'customers_schema.dart';

abstract class CustomersOfflineRepository {
  DbCall<List<CustomerAddressRow>> getCustomerAddresses({
    int? branchId,
    String? name,
    String? phone,
  });

  /// Fetches all addresses for a single customer (for refresh after add/update).
  DbCall<List<CustomerAddressRow>> getCustomerById(int customerId);

  /// Deletes a customer and all their addresses.
  DbCall<void> deleteCustomer(int customerId);
}

class CustomersOfflineRepoImpl implements CustomersOfflineRepository {
  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, List<CustomerAddressRow>>>
  getCustomerAddresses({int? branchId, String? name, String? phone}) async {
    try {
      final conditions = <String>[];
      final args = <Object?>[];

      if (name != null && name.trim().isNotEmpty) {
        conditions.add('c.${CustomersSchema.colName} LIKE ?');
        args.add('%${name.trim()}%');
      }
      if (phone != null && phone.trim().isNotEmpty) {
        conditions.add('c.${CustomersSchema.colPhone} LIKE ?');
        args.add('%${phone.trim()}%');
      }
      if (branchId != null) {
        conditions.add('z.${ZonesSchema.colBranchId} = ?');
        args.add(branchId);
      }

      final where = conditions.isEmpty
          ? ''
          : 'WHERE ${conditions.join(' AND ')}';
      final sql = CustomerAddressesSchema.getCustomerAddressesSql(where);

      final rows = await _db.rawQuery(sql, args);
      return Right(rows.map((e) => CustomerAddressRow.fromMap(e)).toList());
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.queryFailed(e),
      );
    }
  }

  @override
  Future<Either<OfflineFailure, List<CustomerAddressRow>>> getCustomerById(
    int customerId,
  ) async {
    try {
      final where = 'WHERE c.${CustomersSchema.colId} = ?';
      final sql = CustomerAddressesSchema.getCustomerAddressesSql(where);
      final rows = await _db.rawQuery(sql, [customerId]);
      return Right(rows.map((e) => CustomerAddressRow.fromMap(e)).toList());
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.queryFailed(e),
      );
    }
  }

  @override
  Future<Either<OfflineFailure, void>> deleteCustomer(int customerId) async {
    try {
      await _db.delete(
        CustomerAddressesSchema.tableCustomerAddresses,
        where: '${CustomerAddressesSchema.colCustomerId} = ?',
        whereArgs: [customerId],
      );
      await _db.delete(
        CustomersSchema.tableCustomers,
        where: '${CustomersSchema.colId} = ?',
        whereArgs: [customerId],
      );
      return const Right(null);
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.deleteFailed(e),
      );
    }
  }
}
