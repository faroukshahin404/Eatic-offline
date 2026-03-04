import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../../restaurant_tables/model/restaurant_table_model.dart';
import '../../../restaurant_tables/repos/offline/restaurant_tables_schema.dart';

abstract class AddNewRestaurantTableOfflineRepository {
  DbCall<RestaurantTableModel?> getById(int id);
  DbCall<int> insert(RestaurantTableModel model);
  DbCall<int> update(RestaurantTableModel model);
}

class AddNewRestaurantTableOfflineRepoImpl
    implements AddNewRestaurantTableOfflineRepository {
  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, RestaurantTableModel?>> getById(int id) async {
    try {
      final list = await _db.query(
        RestaurantTablesSchema.tableRestaurantTables,
        where: '${RestaurantTablesSchema.colId} = ?',
        whereArgs: [id],
      );
      if (list.isEmpty) return const Right(null);
      return Right(RestaurantTableModel.fromMap(list.first));
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.queryFailed(e),
      );
    }
  }

  @override
  Future<Either<OfflineFailure, int>> insert(RestaurantTableModel model) async {
    try {
      final id = await _db.insert(
        RestaurantTablesSchema.tableRestaurantTables,
        model.toInsertMap(),
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
  Future<Either<OfflineFailure, int>> update(RestaurantTableModel model) async {
    if (model.id == null) {
      return Left(
        OfflineFailure.invalidArgument(
            'RestaurantTableModel.id must be set for update'),
      );
    }
    try {
      final count = await _db.update(
        RestaurantTablesSchema.tableRestaurantTables,
        model.toUpdateMap(),
        where: '${RestaurantTablesSchema.colId} = ?',
        whereArgs: [model.id],
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
