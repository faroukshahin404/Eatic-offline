import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../../addons/model/addon_model.dart';
import '../../../addons/repos/offline/addons_schema.dart';

abstract class AddNewAddonOfflineRepository {
  DbCall<AddonModel?> getById(int id);
  DbCall<int> insert(AddonModel model);
  DbCall<int> update(AddonModel model);
}

class AddNewAddonOfflineRepoImpl implements AddNewAddonOfflineRepository {
  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, AddonModel?>> getById(int id) async {
    try {
      final list = await _db.query(
        AddonsSchema.tableAddons,
        where: '${AddonsSchema.colId} = ?',
        whereArgs: [id],
      );
      if (list.isEmpty) return const Right(null);
      return Right(AddonModel.fromMap(list.first));
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.queryFailed(e),
      );
    }
  }

  @override
  Future<Either<OfflineFailure, int>> insert(AddonModel model) async {
    try {
      final id = await _db.insert(
        AddonsSchema.tableAddons,
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
  Future<Either<OfflineFailure, int>> update(AddonModel model) async {
    if (model.id == null) {
      return Left(
        OfflineFailure.invalidArgument('AddonModel.id must be set for update'),
      );
    }
    try {
      final count = await _db.update(
        AddonsSchema.tableAddons,
        model.toUpdateMap(),
        where: '${AddonsSchema.colId} = ?',
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
