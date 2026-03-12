import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../../customers/repos/offline/customers_schema.dart';
import '../../model/customer_model.dart';

abstract class AddCustomersOfflineRepository {
  /// Inserts customer and then all addresses; returns the new customer id.
  DbCall<int> insert(CustomerModel customer);
}

class AddCustomersOfflineRepoImpl implements AddCustomersOfflineRepository {
  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, int>> insert(CustomerModel customer) async {
    try {
      final now = DateTime.now().toIso8601String();
      final id = await _db.insert(
        CustomersSchema.tableCustomers,
        customer.toInsertMap(now),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      for (final address in customer.addresses) {
        await _db.insert(
          CustomerAddressesSchema.tableCustomerAddresses,
          address.toInsertMap(customerId: id, now: now),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      return Right(id);
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.insertFailed(e),
      );
    }
  }
}
