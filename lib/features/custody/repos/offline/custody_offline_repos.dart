import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../model/custody_model.dart';
import 'custody_schema.dart';

abstract class CustodyOfflineRepository {
  DbCall<CustodyModel> add(CustodyModel custody);
  DbCall<void> update(CustodyModel custody);
  DbCall<CustodyModel?> getById(int id);
  /// Last opened custody (most recent by id, where is_closed = false).
  DbCall<CustodyModel?> getLastOpenCustody();
}

class CustodyOfflineRepoImpl implements CustodyOfflineRepository {
  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, CustodyModel>> add(CustodyModel custody) async {
    try {
      final id = await _db.insert(
        CustodySchema.tableCustody,
        custody.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      final created = custody.copyWith(id: id);
      return Right(created);
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.insertFailed(e),
      );
    }
  }

  @override
  Future<Either<OfflineFailure, void>> update(CustodyModel custody) async {
    if (custody.id == null) {
      return Left(OfflineFailure.invalidArgument('Custody id is null'));
    }
    try {
      await _db.update(
        CustodySchema.tableCustody,
        custody.toMap(),
        where: '${CustodySchema.colId} = ?',
        whereArgs: [custody.id],
      );
      return const Right(null);
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.queryFailed(e),
      );
    }
  }

  @override
  Future<Either<OfflineFailure, CustodyModel?>> getById(int id) async {
    try {
      final rows = await _db.query(
        CustodySchema.tableCustody,
        where: '${CustodySchema.colId} = ?',
        whereArgs: [id],
      );
      if (rows.isEmpty) return const Right(null);
      return Right(CustodyModel.fromMap(rows.first));
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.queryFailed(e),
      );
    }
  }

  @override
  Future<Either<OfflineFailure, CustodyModel?>> getLastOpenCustody() async {
    try {
      final rows = await _db.query(
        CustodySchema.tableCustody,
        where: '${CustodySchema.colIsClosed} = ?',
        whereArgs: [0],
        orderBy: '${CustodySchema.colId} DESC',
        limit: 1,
      );
      if (rows.isEmpty) return const Right(null);
      return Right(CustodyModel.fromMap(rows.first));
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.queryFailed(e),
      );
    }
  }
}
