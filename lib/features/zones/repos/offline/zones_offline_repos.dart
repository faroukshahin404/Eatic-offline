import 'package:dartz/dartz.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../model/zone_model.dart';
import 'zones_schema.dart';

abstract class ZonesOfflineRepository {
  DbCall<List<ZoneModel>> getAllZones();

  /// Zones for the given branch (for user-scoped forms).
  DbCall<List<ZoneModel>> getZonesByBranchId(int branchId);

  DbCall<int> deleteById(int id);
}

class ZonesOfflineRepoImpl implements ZonesOfflineRepository {
  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, List<ZoneModel>>> getAllZones() async {
    try {
      final list = await _db.rawQuery(ZonesSchema.sqlQuery);
      return Right(list.map((e) => ZoneModel.fromMap(e)).toList());
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.queryFailed(e),
      );
    }
  }

  @override
  Future<Either<OfflineFailure, List<ZoneModel>>> getZonesByBranchId(
    int branchId,
  ) async {
    try {
      final list = await _db.rawQuery(
        ZonesSchema.sqlQueryByBranchId,
        [branchId],
      );
      return Right(list.map((e) => ZoneModel.fromMap(e)).toList());
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
        ZonesSchema.tableZones,
        where: '${ZonesSchema.colId} = ?',
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
