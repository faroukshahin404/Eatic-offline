import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/core_models/role_model.dart';
import '../../../../core/core_repos/offline/roles/roles_schema.dart';
import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../../users/model/user_model.dart';
import '../../../users/repos/offline/users_schema.dart';

abstract class AddUserOfflineRepository {
  DbCall<int> create(UserModel user);
  DbCall<int> update(UserModel user);
  DbCall<int> updatePassword(int userId, String newPassword);
  DbCall<UserModel?> getById(int id);
  DbCall<List<RoleModel>> getRoles();
}

class AddUserOfflineRepoImpl implements AddUserOfflineRepository {
  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, int>> create(UserModel user) async {
    try {
      final id = await _db.insert(
        UsersSchema.tableUsers,
        user.toInsertMap(),
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
  Future<Either<OfflineFailure, int>> update(UserModel user) async {
    if (user.id == null) {
      return Left(
        OfflineFailure.invalidArgument('UserModel.id must be set for update'),
      );
    }
    try {
      final count = await _db.update(
        UsersSchema.tableUsers,
        user.toUpdateMap(),
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

  @override
  Future<Either<OfflineFailure, int>> updatePassword(int userId, String newPassword) async {
    final userResult = await getById(userId);
    if (userResult.isLeft()) {
      return userResult.fold((f) => Left(f), (_) => Right(0));
    }
    final user = userResult.getOrElse(() => null);
    if (user == null) {
      return Left(
        OfflineFailure.invalidArgument('User not found for id: $userId'),
      );
    }
    final now = DateTime.now().toIso8601String();
    final updated = user.copyWith(password: newPassword, updatedAt: now);
    return update(updated);
  }

  @override
  Future<Either<OfflineFailure, UserModel?>> getById(int id) async {
    try {
      final list = await _db.query(
        UsersSchema.tableUsers,
        where: '${UsersSchema.colId} = ?',
        whereArgs: [id],
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

  @override
  Future<Either<OfflineFailure, List<RoleModel>>> getRoles() async {
    try {
      final list = await _db.query(RolesStatement.tableRoles);
      return Right(list.map((row) => RoleModel.fromMap(row)).toList());
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.queryFailed(e),
      );
    }
  }
}
