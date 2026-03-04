import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../model/restaurant_table_model.dart';
import 'restaurant_tables_schema.dart';

abstract class RestaurantTablesOfflineRepository {
  DbCall<List<RestaurantTableModel>> getAll();
  DbCall<int> deleteById(int id);
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
}
