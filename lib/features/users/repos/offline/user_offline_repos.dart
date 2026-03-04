import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../model/user_model.dart';
import 'users_schema.dart';

abstract class UserOfflineRepository {
  DbCall<List<UserModel>> getAll({
    String? orderBy,
    int limit = 10,
    int page = 0,
  });
  DbCall<int> deleteById(int id);
}

class UsersOfflineRepoImpl implements UserOfflineRepository {
  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, List<UserModel>>> getAll({
    String? orderBy,
    int limit = 10,
    int page = 0,
  }) async {
    try {
      final offset = page * limit;
      final list = await _db.query(
        UsersSchema.tableUsers,
        orderBy: orderBy ?? UsersSchema.colId,
        limit: limit,
        offset: offset,
      );
      return Right(list.map((e) => UserModel.fromMap(e)).toList());
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
        UsersSchema.tableUsers,
        where: '${UsersSchema.colId} = ?',
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
