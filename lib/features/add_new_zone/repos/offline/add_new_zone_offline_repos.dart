import 'package:dartz/dartz.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../../zones/model/zone_model.dart';
import '../../../zones/repos/offline/zones_schema.dart';
import 'add_new_zone_offline_schema.dart';

abstract class AddNewZoneOfflineRepository {
  DbCall<ZoneModel?> getZoneById(int id);
  DbCall<int> insert(ZoneModel model);
  DbCall<int> update(ZoneModel model);
}

class AddNewZoneOfflineRepoImpl implements AddNewZoneOfflineRepository {
  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, ZoneModel?>> getZoneById(int id) async {
    try {
      final list = await _db.rawQuery(
        AddNewZoneOfflineSchema.sqlGetZoneById,
        [id],
      );
      if (list.isEmpty) return const Right(null);
      return Right(ZoneModel.fromMap(list.first));
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.queryFailed(e),
      );
    }
  }

  @override
  Future<Either<OfflineFailure, int>> insert(ZoneModel model) async {
    try {
      final map = model.toInsertMap();
      final id = await _db.insert(
        ZonesSchema.tableZones,
        map,
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
  Future<Either<OfflineFailure, int>> update(ZoneModel model) async {
    if (model.id == null) {
      return Left(
        OfflineFailure.invalidArgument('ZoneModel.id must be set for update'),
      );
    }
    try {
      final count = await _db.update(
        ZonesSchema.tableZones,
        model.toUpdateMap(),
        where: '${ZonesSchema.colId} = ?',
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
