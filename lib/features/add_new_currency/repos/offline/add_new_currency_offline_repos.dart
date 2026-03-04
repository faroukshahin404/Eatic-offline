import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../../currencies/model/currency_model.dart';
import '../../../currencies/repos/offline/currencies_schema.dart';

abstract class AddNewCurrencyOfflineRepository {
  DbCall<CurrencyModel?> getCurrencyById(int id);
  DbCall<int> insert(CurrencyModel model);
  DbCall<int> update(CurrencyModel model);
}

class AddNewCurrencyOfflineRepoImpl implements AddNewCurrencyOfflineRepository {
  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, CurrencyModel?>> getCurrencyById(int id) async {
    try {
      final list = await _db.query(
        CurrenciesSchema.tableCurrencies,
        where: '${CurrenciesSchema.colId} = ?',
        whereArgs: [id],
      );
      if (list.isEmpty) return const Right(null);
      return Right(CurrencyModel.fromMap(list.first));
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.queryFailed(e),
      );
    }
  }

  @override
  Future<Either<OfflineFailure, int>> insert(CurrencyModel model) async {
    try {
      final map = model.toInsertMap();
      final id = await _db.insert(
        CurrenciesSchema.tableCurrencies,
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
  Future<Either<OfflineFailure, int>> update(CurrencyModel model) async {
    if (model.id == null) {
      return Left(
        OfflineFailure.invalidArgument(
          'CurrencyModel.id must be set for update',
        ),
      );
    }
    try {
      final count = await _db.update(
        CurrenciesSchema.tableCurrencies,
        model.toUpdateMap(),
        where: '${CurrenciesSchema.colId} = ?',
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
