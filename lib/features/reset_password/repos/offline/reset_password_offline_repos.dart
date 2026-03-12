import 'package:dartz/dartz.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../../users/model/user_model.dart';
import '../../../users/repos/offline/users_schema.dart';

abstract class ResetPasswordOfflineRepository {
  DbCall<int> updatePassword(UserModel user);
}

class ResetPasswordOfflineRepoImpl implements ResetPasswordOfflineRepository {
  ResetPasswordOfflineRepoImpl();

  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, int>> updatePassword(UserModel user) async {
    if (user.id == null) {
      return Left(
        OfflineFailure.invalidArgument('UserModel.id must be set for update'),
      );
    }
    try {
      final count = await _db.update(
        UsersSchema.tableUsers,
        {
          UsersSchema.colPassword: user.password,
          UsersSchema.colUpdatedAt: user.updatedAt,
        },
        where: '${UsersSchema.colId} = ?',
        whereArgs: [user.id],
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
