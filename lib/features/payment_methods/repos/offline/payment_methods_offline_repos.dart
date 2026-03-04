import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../model/payment_method_model.dart';
import 'payment_methods_schema.dart';

abstract class PaymentMethodsOfflineRepository {
  DbCall<List<PaymentMethodModel>> getAll();
  DbCall<int> deleteById(int id);
}

class PaymentMethodsOfflineRepoImpl implements PaymentMethodsOfflineRepository {
  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, List<PaymentMethodModel>>> getAll() async {
    try {
      final list = await _db.rawQuery(PaymentMethodsSchema.sqlQuery);
      return Right(
          list.map((e) => PaymentMethodModel.fromMap(e)).toList());
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
        PaymentMethodsSchema.tablePaymentMethods,
        where: '${PaymentMethodsSchema.colId} = ?',
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
