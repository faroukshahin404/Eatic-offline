import 'package:dartz/dartz.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../model/restaurant_table_model.dart';
import 'restaurant_tables_schema.dart';

abstract class RestaurantTablesOfflineRepository {
  DbCall<List<RestaurantTableModel>> getAll();

  /// Returns tables that belong to the given [branchId].
  DbCall<List<RestaurantTableModel>> getByBranchId(int branchId);

  DbCall<int> deleteById(int id);

  /// Updates the table's [isEmpty] flag (0 = occupied, 1 = empty).
  DbCall<int> updateTableIsEmpty(int tableId, int isEmpty);
}

class RestaurantTablesOfflineRepoImpl
    implements RestaurantTablesOfflineRepository {
  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, List<RestaurantTableModel>>> getAll() async {
    try {
      final list = await _db.rawQuery(RestaurantTablesSchema.sqlQuery);
      return Right(
          list.map((e) => RestaurantTableModel.fromMap(e)).toList());
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.queryFailed(e),
      );
    }
  }

  @override
  Future<Either<OfflineFailure, List<RestaurantTableModel>>> getByBranchId(
    int branchId,
  ) async {
    try {
      final list = await _db.rawQuery(
        RestaurantTablesSchema.sqlQueryByBranchId,
        [branchId],
      );
      return Right(
          list.map((e) => RestaurantTableModel.fromMap(e)).toList());
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.queryFailed(e),
      );
    }
  }

  @override
  Future<Either<OfflineFailure, int>> deleteById(int id) async {
    try {
      final count = await _db.delete(
        RestaurantTablesSchema.tableRestaurantTables,
        where: '${RestaurantTablesSchema.colId} = ?',
        whereArgs: [id],
      );
      return Right(count);
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.deleteFailed(e),
      );
    }
  }

  @override
  Future<Either<OfflineFailure, int>> updateTableIsEmpty(
    int tableId,
    int isEmpty,
  ) async {
    try {
      final count = await _db.update(
        RestaurantTablesSchema.tableRestaurantTables,
        {
          RestaurantTablesSchema.colIsEmpty: isEmpty,
          RestaurantTablesSchema.colUpdatedAt: DateTime.now().toIso8601String(),
        },
        where: '${RestaurantTablesSchema.colId} = ?',
        whereArgs: [tableId],
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
}
