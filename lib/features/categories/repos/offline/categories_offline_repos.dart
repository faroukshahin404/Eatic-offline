import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../model/category_model.dart';
import 'categories_schema.dart';

abstract class CategoriesOfflineRepository {
  DbCall<List<CategoryModel>> getAll();
  DbCall<int> deleteById(int id);
}

class CategoriesOfflineRepoImpl implements CategoriesOfflineRepository {
  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, List<CategoryModel>>> getAll() async {
    try {
      final list = await _db.rawQuery(CategoriesSchema.sqlQuery);
      return Right(
          list.map((e) => CategoryModel.fromMap(e)).toList());
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
        CategoriesSchema.tableCategories,
        where: '${CategoriesSchema.colId} = ?',
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
