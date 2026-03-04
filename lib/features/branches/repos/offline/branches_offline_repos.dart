import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../model/branch_model.dart';
import '../../../users/repos/offline/users_schema.dart';
import 'branches_schema.dart';

abstract class BranchesOfflineRepository {
  DbCall<List<BranchModel>> getAll();
  DbCall<int> remove(int id);
}

class BranchesOfflineRepoImpl implements BranchesOfflineRepository {
  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, List<BranchModel>>> getAll() async {
    try {
      final list = await _db.query(BranchesSchema.tableBranches);
      final branches = <BranchModel>[];
      for (final row in list) {
        final rowMap = Map<String, dynamic>.from(row);
        final createdById = rowMap[BranchesSchema.colCreatedBy] as int?;
        if (createdById != null) {
          final userRows = await _db.query(
            UsersSchema.tableUsers,
            where: '${UsersSchema.colId} = ?',
            whereArgs: [createdById],
          );
          if (userRows.isNotEmpty) {
            rowMap['created_by_user'] = userRows.first;
          }
        }
        branches.add(BranchModel.fromMap(rowMap));
      }
      return Right(branches);
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.queryFailed(e),
      );
    }
  }

 
  @override
  Future<Either<OfflineFailure, int>> remove(int id) async {
    try {
      final count = await _db.delete(
        BranchesSchema.tableBranches,
        where: '${BranchesSchema.colId} = ?',
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
