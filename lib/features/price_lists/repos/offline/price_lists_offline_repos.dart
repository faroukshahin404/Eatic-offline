import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../model/price_list_model.dart';
import 'price_lists_schema.dart';

abstract class PriceListsOfflineRepository {
  DbCall<List<PriceListModel>> getAll();
  DbCall<int> deleteById(int id);
}

class PriceListsOfflineRepoImpl implements PriceListsOfflineRepository {
  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, List<PriceListModel>>> getAll() async {
    try {
      final list = await _db.rawQuery(PriceListsSchema.sqlQuery);
      return Right(
          list.map((e) => PriceListModel.fromMap(e)).toList());
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
        PriceListsSchema.tablePriceLists,
        where: '${PriceListsSchema.colId} = ?',
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
