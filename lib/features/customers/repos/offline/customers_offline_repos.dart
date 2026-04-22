import 'package:dartz/dartz.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../../add_customers/model/address_model.dart';
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

  /// Creates customer and returns new id.
  DbCall<int> insertCustomer({required String name, required String phone});

  /// Inserts one address and returns inserted address id.
  DbCall<int> insertAddress({
    required int customerId,
    required AddressModel address,
  });

  /// Updates one address by id.
  DbCall<void> updateAddress({
    required int addressId,
    required AddressModel address,
  });

  /// Deletes one address by id.
  DbCall<void> deleteAddress(int addressId);
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

      final where =
          conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}';
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

  @override
  Future<Either<OfflineFailure, int>> insertCustomer({
    required String name,
    required String phone,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      final id = await _db.insert(
        CustomersSchema.tableCustomers,
        {
          CustomersSchema.colName: name.trim().isEmpty ? null : name.trim(),
          CustomersSchema.colPhone: phone.trim(),
          CustomersSchema.colCreatedAt: now,
          CustomersSchema.colUpdatedAt: now,
        },
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
  Future<Either<OfflineFailure, int>> insertAddress({
    required int customerId,
    required AddressModel address,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      final id = await _db.insert(
        CustomerAddressesSchema.tableCustomerAddresses,
        address.toInsertMap(customerId: customerId, now: now),
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
  Future<Either<OfflineFailure, void>> updateAddress({
    required int addressId,
    required AddressModel address,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      await _db.update(
        CustomerAddressesSchema.tableCustomerAddresses,
        {
          CustomerAddressesSchema.colZoneId: address.zoneId,
          CustomerAddressesSchema.colApartment: address.apartment,
          CustomerAddressesSchema.colFloor: address.floor,
          CustomerAddressesSchema.colBuildingNumber: address.buildingNumber,
          CustomerAddressesSchema.colIsDefault: address.isDefault ? 1 : 0,
          CustomerAddressesSchema.colUpdatedAt: now,
        },
        where: '${CustomerAddressesSchema.colId} = ?',
        whereArgs: [addressId],
      );
      return const Right(null);
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.updateFailed(e),
      );
    }
  }

  @override
  Future<Either<OfflineFailure, void>> deleteAddress(int addressId) async {
    try {
      await _db.delete(
        CustomerAddressesSchema.tableCustomerAddresses,
        where: '${CustomerAddressesSchema.colId} = ?',
        whereArgs: [addressId],
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
