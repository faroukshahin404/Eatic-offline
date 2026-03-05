import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../../currencies/repos/offline/currencies_schema.dart';
import '../../../price_lists/model/price_list_model.dart';
import '../../../price_lists/repos/offline/price_lists_schema.dart';

abstract class AddNewPriceListOfflineRepository {
  DbCall<PriceListModel?> getById(int id);
  DbCall<int> insert(PriceListModel model);
  DbCall<int> update(PriceListModel model);
}

class AddNewPriceListOfflineRepoImpl implements AddNewPriceListOfflineRepository {
  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, PriceListModel?>> getById(int id) async {
    try {
      final rows = await _db.query(
        PriceListsSchema.tablePriceLists,
        where: '${PriceListsSchema.colId} = ?',
        whereArgs: [id],
      );
      if (rows.isEmpty) return const Right(null);
      final r = rows.first;
      final currencyId = r[PriceListsSchema.colCurrencyId] as int?;
      String? currencyName;
      if (currencyId != null) {
        final cur = await _db.query(
          CurrenciesSchema.tableCurrencies,
          where: '${CurrenciesSchema.colId} = ?',
          whereArgs: [currencyId],
        );
        if (cur.isNotEmpty) {
          currencyName = cur.first[CurrenciesSchema.colName] as String?;
        }
      }
      return Right(PriceListModel.fromMap({
        ...r,
        'currency_name': currencyName,
      }));
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.queryFailed(e),
      );
    }
  }

  @override
  Future<Either<OfflineFailure, int>> insert(PriceListModel model) async {
    try {
      final id = await _db.insert(
        PriceListsSchema.tablePriceLists,
        model.toInsertMap(),
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
  Future<Either<OfflineFailure, int>> update(PriceListModel model) async {
    if (model.id == null) {
      return Left(OfflineFailure.invalidArgument(
          'PriceListModel.id must be set for update'));
    }
    try {
      final count = await _db.update(
        PriceListsSchema.tablePriceLists,
        model.toUpdateMap(),
        where: '${PriceListsSchema.colId} = ?',
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
