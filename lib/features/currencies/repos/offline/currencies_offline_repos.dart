import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../model/currency_model.dart';
import 'currencies_schema.dart';

abstract class CurrenciesOfflineRepository {
  DbCall<List<CurrencyModel>> getAll();
  DbCall<int> deleteById(int id);
}

class CurrenciesOfflineRepoImpl implements CurrenciesOfflineRepository {
  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, List<CurrencyModel>>> getAll() async {
    try {
      final list = await _db.rawQuery(CurrenciesSchema.sqlQuery);
      return Right(list.map((e) => CurrencyModel.fromMap(e)).toList());
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
        CurrenciesSchema.tableCurrencies,
        where: '${CurrenciesSchema.colId} = ?',
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
