import 'package:dartz/dartz.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../../payment_methods/model/payment_method_model.dart';
import '../../../payment_methods/repos/offline/payment_methods_schema.dart';

abstract class AddNewPaymentMethodOfflineRepository {
  DbCall<int> insert(PaymentMethodModel model);
  DbCall<int> update(PaymentMethodModel model);
}

class AddNewPaymentMethodOfflineRepoImpl
    implements AddNewPaymentMethodOfflineRepository {
  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, int>> insert(PaymentMethodModel model) async {
    try {
      final id = await _db.insert(
        PaymentMethodsSchema.tablePaymentMethods,
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
  Future<Either<OfflineFailure, int>> update(PaymentMethodModel model) async {
    if (model.id == null) {
      return Left(
        OfflineFailure.invalidArgument(
            'PaymentMethodModel.id must be set for update'),
      );
    }
    try {
      final count = await _db.update(
        PaymentMethodsSchema.tablePaymentMethods,
        model.toUpdateMap(),
        where: '${PaymentMethodsSchema.colId} = ?',
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
