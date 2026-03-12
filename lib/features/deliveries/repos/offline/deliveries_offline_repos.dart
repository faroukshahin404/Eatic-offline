import 'package:dartz/dartz.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../model/delivery_model.dart';
import 'deliveries_schema.dart';

abstract class DeliveriesOfflineRepository {
  DbCall<List<DeliveryModel>> getAll();
  DbCall<int> deleteById(int id);
}

class DeliveriesOfflineRepoImpl implements DeliveriesOfflineRepository {
  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, List<DeliveryModel>>> getAll() async {
    try {
      
      final list = await _db.rawQuery(DeliveryMenSchema.sqlQuery);
      return Right(list.map((e) => DeliveryModel.fromMap(e)).toList());
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
        DeliveryMenSchema.tableDeliveryMen,
        where: '${DeliveryMenSchema.colId} = ?',
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
