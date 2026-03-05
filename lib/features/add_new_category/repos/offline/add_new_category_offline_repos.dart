import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../../categories/model/category_model.dart';
import '../../../categories/repos/offline/categories_schema.dart';

abstract class AddNewCategoryOfflineRepository {
  DbCall<CategoryModel?> getById(int id);
  DbCall<int> insert(CategoryModel model);
  DbCall<int> update(CategoryModel model);
}

class AddNewCategoryOfflineRepoImpl implements AddNewCategoryOfflineRepository {
  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, CategoryModel?>> getById(int id) async {
    try {
      final list = await _db.query(
        CategoriesSchema.tableCategories,
        where: '${CategoriesSchema.colId} = ?',
        whereArgs: [id],
      );
      if (list.isEmpty) return const Right(null);
      return Right(CategoryModel.fromMap(list.first));
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.queryFailed(e),
      );
    }
  }

  @override
  Future<Either<OfflineFailure, int>> insert(CategoryModel model) async {
    try {
      final id = await _db.insert(
        CategoriesSchema.tableCategories,
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
  Future<Either<OfflineFailure, int>> update(CategoryModel model) async {
    if (model.id == null) {
      return Left(
        OfflineFailure.invalidArgument(
          'CategoryModel.id must be set for update',
        ),
      );
    }
    try {
      final count = await _db.update(
        CategoriesSchema.tableCategories,
        model.toUpdateMap(),
        where: '${CategoriesSchema.colId} = ?',
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
