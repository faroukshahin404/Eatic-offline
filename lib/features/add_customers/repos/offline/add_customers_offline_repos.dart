import 'package:dartz/dartz.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../../customers/repos/offline/customers_schema.dart';
import '../../model/address_model.dart';
import '../../model/customer_model.dart';

abstract class AddCustomersOfflineRepository {
  /// Inserts customer and then all addresses; returns the new customer id.
  DbCall<int> insert(CustomerModel customer);

  /// Inserts new addresses for an existing customer (e.g. "Add New Address" flow).
  DbCall<void> insertAddressesForCustomer(
    int customerId,
    List<AddressModel> addresses,
  );

  /// Fetches customer by id with all addresses (for editing / add-address flow).
  DbCall<CustomerModel> getCustomerById(int customerId);
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

  @override
  Future<Either<OfflineFailure, void>> insertAddressesForCustomer(
    int customerId,
    List<AddressModel> addresses,
  ) async {
    try {
      final now = DateTime.now().toIso8601String();
      for (final address in addresses) {
        await _db.insert(
          CustomerAddressesSchema.tableCustomerAddresses,
          address.toInsertMap(customerId: customerId, now: now),
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
  Future<Either<OfflineFailure, CustomerModel>> getCustomerById(
    int customerId,
  ) async {
    try {
      final customerRows = await _db.query(
        CustomersSchema.tableCustomers,
        where: '${CustomersSchema.colId} = ?',
        whereArgs: [customerId],
      );
      if (customerRows.isEmpty) {
        return Left(OfflineFailure.invalidArgument('Customer not found'));
      }
      final customerMap = customerRows.first;
      final addressRows = await _db.query(
        CustomerAddressesSchema.tableCustomerAddresses,
        where: '${CustomerAddressesSchema.colCustomerId} = ?',
        whereArgs: [customerId],
      );
      final addresses = addressRows
          .map((m) => AddressModel.fromMap(m))
          .toList();
      final customer = CustomerModel(
        id: customerId,
        phone: customerMap[CustomersSchema.colPhone] as String,
        name: customerMap[CustomersSchema.colName] as String?,
        secondPhone: customerMap[CustomersSchema.colSecondPhone] as String?,
        createdAt: customerMap[CustomersSchema.colCreatedAt] as String?,
        updatedAt: customerMap[CustomersSchema.colUpdatedAt] as String?,
        addresses: addresses,
      );
      return Right(customer);
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.queryFailed(e),
      );
    }
  }
}
