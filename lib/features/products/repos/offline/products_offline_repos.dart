import 'package:dartz/dartz.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../../add_new_product/model/product_model.dart';
import '../../../add_new_product/repos/offline/products_schema.dart';
import '../../../categories/repos/offline/categories_schema.dart';

abstract class ProductsOfflineRepository {
  DbCall<List<ProductModel>> getAllProducts();
  /// When [categoryId] is null, returns all products. Otherwise returns products in that category.
  DbCall<List<ProductModel>> getProductsByCategoryId(int? categoryId);
  DbCall<void> deleteProduct(int productId);
}

class ProductsOfflineRepoImpl implements ProductsOfflineRepository {
  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, List<ProductModel>>> getAllProducts() async {
    return getProductsByCategoryId(null);
  }

  static String _categoryNamesSubquery(String productAlias) {
    return '''
(SELECT GROUP_CONCAT(c.${CategoriesSchema.colName}, ', ')
 FROM ${ProductsSchema.tableCategoryProduct} cp
 INNER JOIN ${CategoriesSchema.tableCategories} c
   ON c.${CategoriesSchema.colId} = cp.${ProductsSchema.colCategoryId}
 WHERE cp.${ProductsSchema.colProductId} = $productAlias.${ProductsSchema.colId}
) AS category_names''';
  }

  @override
  Future<Either<OfflineFailure, List<ProductModel>>> getProductsByCategoryId(
    int? categoryId,
  ) async {
    try {
      final List<Map<String, dynamic>> rows;
      if (categoryId == null) {
        rows = await _db.rawQuery(
          '''
          SELECT p.*, ${_categoryNamesSubquery('p')}
          FROM ${ProductsSchema.tableProducts} p
          ORDER BY p.${ProductsSchema.colSortOrder} ASC, p.${ProductsSchema.colId} ASC
          ''',
        );
      } else {
        rows = await _db.rawQuery(
          '''
          SELECT p.*, ${_categoryNamesSubquery('p')}
          FROM ${ProductsSchema.tableProducts} p
          INNER JOIN ${ProductsSchema.tableCategoryProduct} cpf
            ON p.${ProductsSchema.colId} = cpf.${ProductsSchema.colProductId}
          WHERE cpf.${ProductsSchema.colCategoryId} = ?
          ORDER BY p.${ProductsSchema.colSortOrder} ASC, p.${ProductsSchema.colId} ASC
          ''',
          [categoryId],
        );
      }
      final list = rows.map((m) => ProductModel.fromMap(m)).toList();
      return Right(list);
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.queryFailed(e),
      );
    }
  }

  @override
  Future<Either<OfflineFailure, void>> deleteProduct(int productId) async {
    try {
      await _deleteProductVariantsAndVariables(productId);
      await _db.delete(
        ProductsSchema.tableProductAddon,
        where: '${ProductsSchema.colProductId} = ?',
        whereArgs: [productId],
      );
      await _db.delete(
        ProductsSchema.tableCategoryProduct,
        where: '${ProductsSchema.colProductId} = ?',
        whereArgs: [productId],
      );
      await _db.delete(
        ProductsSchema.tableProductPriceListPrices,
        where: '${ProductsSchema.colProductId} = ?',
        whereArgs: [productId],
      );
      await _db.delete(
        ProductsSchema.tableProducts,
        where: '${ProductsSchema.colId} = ?',
        whereArgs: [productId],
      );
      return const Right(null);
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.deleteFailed(e),
      );
    }
  }

  /// Deletes all variants and variables for a product (and their child rows).
  Future<void> _deleteProductVariantsAndVariables(int productId) async {
    final variantRows = await _db.query(
      ProductsSchema.tableProductVariants,
      columns: [ProductsSchema.colId],
      where: '${ProductsSchema.colProductId} = ?',
      whereArgs: [productId],
    );
    for (final v in variantRows) {
      final variantId = v[ProductsSchema.colId] as int;
      await _db.delete(
        ProductsSchema.tableProductVariantValues,
        where: '${ProductsSchema.colProductVariantId} = ?',
        whereArgs: [variantId],
      );
      await _db.delete(
        ProductsSchema.tableProductVariantPriceListPrices,
        where: '${ProductsSchema.colProductVariantId} = ?',
        whereArgs: [variantId],
      );
      await _db.delete(
        ProductsSchema.tableProductVariantAddon,
        where: '${ProductsSchema.colProductVariantId} = ?',
        whereArgs: [variantId],
      );
    }
    await _db.delete(
      ProductsSchema.tableProductVariants,
      where: '${ProductsSchema.colProductId} = ?',
      whereArgs: [productId],
    );
    final varRows = await _db.query(
      ProductsSchema.tableProductVariables,
      columns: [ProductsSchema.colId],
      where: '${ProductsSchema.colProductId} = ?',
      whereArgs: [productId],
    );
    for (final vr in varRows) {
      final varId = vr[ProductsSchema.colId] as int;
      await _db.delete(
        ProductsSchema.tableProductVariableValues,
        where: '${ProductsSchema.colProductVariableId} = ?',
        whereArgs: [varId],
      );
    }
    await _db.delete(
      ProductsSchema.tableProductVariables,
      where: '${ProductsSchema.colProductId} = ?',
      whereArgs: [productId],
    );
  }
}

