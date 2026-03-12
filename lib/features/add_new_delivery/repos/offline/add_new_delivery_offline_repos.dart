import 'package:dartz/dartz.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../../branches/repos/offline/branches_schema.dart';
import '../../../deliveries/model/delivery_model.dart';
import '../../../deliveries/repos/offline/deliveries_schema.dart';

abstract class AddNewDeliveryOfflineRepository {
  DbCall<DeliveryModel?> getDeliveryById(int id);
  DbCall<int> insert(DeliveryModel model);
  DbCall<int> update(DeliveryModel model);
}

class AddNewDeliveryOfflineRepoImpl implements AddNewDeliveryOfflineRepository {
  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, DeliveryModel?>> getDeliveryById(int id) async {
    try {
      final sql = '''
        SELECT d.${DeliveryMenSchema.colId}, d.${DeliveryMenSchema.colVendorId},
               d.${DeliveryMenSchema.colBranchId}, d.${DeliveryMenSchema.colName},
               d.${DeliveryMenSchema.colPhone1}, d.${DeliveryMenSchema.colPhone2},
               d.${DeliveryMenSchema.colAddress}, d.${DeliveryMenSchema.colNationalId},
               d.${DeliveryMenSchema.colCreatedAt}, d.${DeliveryMenSchema.colUpdatedAt},
               b.${BranchesSchema.colName} AS branch_name
        FROM ${DeliveryMenSchema.tableDeliveryMen} d
        LEFT JOIN ${BranchesSchema.tableBranches} b ON d.${DeliveryMenSchema.colBranchId} = b.${BranchesSchema.colId}
        WHERE d.${DeliveryMenSchema.colId} = ?
      ''';
      final list = await _db.rawQuery(sql, [id]);
      if (list.isEmpty) return const Right(null);
      return Right(DeliveryModel.fromMap(list.first));
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.queryFailed(e),
      );
    }
  }

  @override
  Future<Either<OfflineFailure, int>> insert(DeliveryModel model) async {
    try {
      final map = model.toInsertMap();
      final id = await _db.insert(
        DeliveryMenSchema.tableDeliveryMen,
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
  Future<Either<OfflineFailure, int>> update(DeliveryModel model) async {
    if (model.id == null) {
      return Left(
        OfflineFailure.invalidArgument(
          'DeliveryModel.id must be set for update',
        ),
      );
    }
    try {
      final count = await _db.update(
        DeliveryMenSchema.tableDeliveryMen,
        model.toUpdateMap(),
        where: '${DeliveryMenSchema.colId} = ?',
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
