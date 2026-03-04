import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../model/dining_area_model.dart';
import 'dining_areas_schema.dart';

abstract class DiningAreasOfflineRepository {
  DbCall<List<DiningAreaModel>> getAll();
  DbCall<int> deleteById(int id);
}

class DiningAreasOfflineRepoImpl implements DiningAreasOfflineRepository {
  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, List<DiningAreaModel>>> getAll() async {
    try {
      final list = await _db.rawQuery(DiningAreasSchema.sqlQuery);
      return Right(
          list.map((e) => DiningAreaModel.fromMap(e)).toList());
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
        DiningAreasSchema.tableDiningAreas,
        where: '${DiningAreasSchema.colId} = ?',
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
