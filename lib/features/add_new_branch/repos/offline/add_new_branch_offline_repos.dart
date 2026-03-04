import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../../branches/model/branch_model.dart';
import '../../../branches/repos/offline/branches_schema.dart';

abstract class AddNewBranchOfflineRepository {
  DbCall<int> create(BranchModel branch);
  DbCall<int> update(BranchModel branch);
  DbCall<BranchModel?> getBranchById(int id);
}

class AddNewBranchOfflineRepoImpl implements AddNewBranchOfflineRepository {
  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, int>> create(BranchModel branch) async {
    try {
      final id = await _db.insert(
        BranchesSchema.tableBranches,
        branch.toInsertMap(),
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
  Future<Either<OfflineFailure, int>> update(BranchModel branch) async {
    if (branch.id == null) {
      return Left(
        OfflineFailure.invalidArgument('BranchModel.id must be set for update'),
      );
    }
    try {
      final count = await _db.update(
        BranchesSchema.tableBranches,
        branch.toUpdateMap(),
        where: '${BranchesSchema.colId} = ?',
        whereArgs: [branch.id],
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

  @override
  Future<Either<OfflineFailure, BranchModel?>> getBranchById(int id) async {
    try {
      final list = await _db.query(
        BranchesSchema.tableBranches,
        where: '${BranchesSchema.colId} = ?',
        whereArgs: [id],
      );
      return Right(
          list.isEmpty ? null : BranchModel.fromMap(list.first));
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.queryFailed(e),
      );
    }
  }
}
