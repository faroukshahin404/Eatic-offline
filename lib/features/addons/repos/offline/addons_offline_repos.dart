import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../model/addon_model.dart';
import 'addons_schema.dart';

abstract class AddonsOfflineRepository {
  DbCall<List<AddonModel>> getAll();
  DbCall<int> deleteById(int id);
}

class AddonsOfflineRepoImpl implements AddonsOfflineRepository {
  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, List<AddonModel>>> getAll() async {
    try {
      final list = await _db.rawQuery(AddonsSchema.sqlQuery);
      return Right(list.map((e) => AddonModel.fromMap(e)).toList());
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
        AddonsSchema.tableAddons,
        where: '${AddonsSchema.colId} = ?',
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
