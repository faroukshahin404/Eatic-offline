import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../../users/model/user_model.dart';
import '../../../users/repos/offline/users_schema.dart';

abstract class LoginOfflineRepository {
  DbCall<UserModel?> findByCodeAndPassword(String code, String password);
}

class LoginOfflineRepoImpl implements LoginOfflineRepository {
  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, UserModel?>> findByCodeAndPassword(
    String code,
    String password,
  ) async {
    try {
      final list = await _db.query(
        UsersSchema.tableUsers,
        where:
            '${UsersSchema.colCode} = ? AND ${UsersSchema.colPassword} = ?',
        whereArgs: [code.trim(), password],
      );
      return Right(list.isEmpty ? null : UserModel.fromMap(list.first));
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.queryFailed(e),
      );
    }
  }
}
