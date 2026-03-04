import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../../dining_areas/model/dining_area_model.dart';
import '../../../dining_areas/repos/offline/dining_areas_schema.dart';

abstract class AddNewDiningAreaOfflineRepository {
  DbCall<DiningAreaModel?> getById(int id);
  DbCall<int> insert(DiningAreaModel model);
  DbCall<int> update(DiningAreaModel model);
}

class AddNewDiningAreaOfflineRepoImpl
    implements AddNewDiningAreaOfflineRepository {
  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, DiningAreaModel?>> getById(int id) async {
    try {
      final list = await _db.query(
        DiningAreasSchema.tableDiningAreas,
        where: '${DiningAreasSchema.colId} = ?',
        whereArgs: [id],
      );
      if (list.isEmpty) return const Right(null);
      return Right(DiningAreaModel.fromMap(list.first));
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.queryFailed(e),
      );
    }
  }

  @override
  Future<Either<OfflineFailure, int>> insert(DiningAreaModel model) async {
    try {
      final id = await _db.insert(
        DiningAreasSchema.tableDiningAreas,
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
  Future<Either<OfflineFailure, int>> update(DiningAreaModel model) async {
    if (model.id == null) {
      return Left(
        OfflineFailure.invalidArgument(
            'DiningAreaModel.id must be set for update'),
      );
    }
    try {
      final count = await _db.update(
        DiningAreasSchema.tableDiningAreas,
        model.toUpdateMap(),
        where: '${DiningAreasSchema.colId} = ?',
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
