import 'package:dartz/dartz.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../model/add_product_input.dart';
import '../../model/product_detail_model.dart';
import '../../model/product_variable_row.dart';
import '../../model/variant_prices_row.dart';
import 'products_schema.dart';

abstract class AddNewProductOfflineRepository {
  DbCall<int> insertProduct(AddProductInput input);
  DbCall<ProductDetailModel> getProductById(int productId);
  DbCall<void> updateProduct(ProductDetailModel detail);
}

/// Returns all combinations of one element from each list (cartesian product).
/// Order: first list varies slowest.
List<List<int>> _cartesianProduct(List<List<int>> lists) {
  if (lists.isEmpty) return [];
  if (lists.length == 1) return lists.first.map((e) => [e]).toList();
  final rest = _cartesianProduct(lists.sublist(1));
  final result = <List<int>>[];
  for (final head in lists.first) {
    for (final tail in rest) {
      result.add([head, ...tail]);
    }
  }
  return result;
}

class AddNewProductOfflineRepoImpl implements AddNewProductOfflineRepository {
  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, int>> insertProduct(AddProductInput input) async {
    try {
      final now = DateTime.now().toIso8601String();
      final productMap = {
        ProductsSchema.colVendorId: null,
        ProductsSchema.colName: input.name,
        ProductsSchema.colNameEn: input.nameEn,
        ProductsSchema.colDescription: input.description,
        ProductsSchema.colImage: null,
        ProductsSchema.colDefaultPrice: null,
        ProductsSchema.colHasVariants: input.hasVariants ? 1 : 0,
        ProductsSchema.colSortOrder: 0,
        ProductsSchema.colCreatedAt: now,
        ProductsSchema.colUpdatedAt: now,
      };
      final productId = await _db.insert(
        ProductsSchema.tableProducts,
        productMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (final catId in input.categoryIds) {
        await _db.insert(
          ProductsSchema.tableCategoryProduct,
          {
            ProductsSchema.colCategoryId: catId,
            ProductsSchema.colProductId: productId,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      if (input.hasVariants && input.variableRows.isNotEmpty) {
        final variableValueIds = <List<int>>[];
        var sortOrder = 0;
        for (final row in input.variableRows) {
          final varId = await _db.insert(
            ProductsSchema.tableProductVariables,
            {
              ProductsSchema.colProductId: productId,
              ProductsSchema.colVariableName: row.name.isEmpty ? ' ' : row.name,
              ProductsSchema.colSortOrder: sortOrder++,
              ProductsSchema.colCreatedAt: now,
              ProductsSchema.colUpdatedAt: now,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          final valueIds = <int>[];
          var valueSort = 0;
          for (final v in row.values) {
            if (v.trim().isEmpty) continue;
            final valueId = await _db.insert(
              ProductsSchema.tableProductVariableValues,
              {
                ProductsSchema.colProductVariableId: varId,
                ProductsSchema.colValue: v.trim(),
                ProductsSchema.colSortOrder: valueSort++,
                ProductsSchema.colCreatedAt: now,
                ProductsSchema.colUpdatedAt: now,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            valueIds.add(valueId);
          }
          if (valueIds.isEmpty) continue;
          variableValueIds.add(valueIds);
        }

        if (variableValueIds.isNotEmpty) {
          final combinations = _cartesianProduct(variableValueIds);
          final variantPricesRows = input.variantPricesRows;
          for (var i = 0; i < combinations.length; i++) {
            final combo = combinations[i];
            final prices = i < variantPricesRows.length
                ? variantPricesRows[i]
                : VariantPricesRow();
            final variantId = await _db.insert(
              ProductsSchema.tableProductVariants,
              {
                ProductsSchema.colProductId: productId,
                ProductsSchema.colBasePrice: prices.basePrice,
                ProductsSchema.colIsActive: prices.isActive ? 1 : 0,
                ProductsSchema.colSortOrder: i,
                ProductsSchema.colCreatedAt: now,
                ProductsSchema.colUpdatedAt: now,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            for (final valueId in combo) {
              await _db.insert(
                ProductsSchema.tableProductVariantValues,
                {
                  ProductsSchema.colProductVariantId: variantId,
                  ProductsSchema.colProductVariableValueId: valueId,
                },
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
            for (final e in prices.priceListPrices.entries) {
              await _db.insert(
                ProductsSchema.tableProductVariantPriceListPrices,
                {
                  ProductsSchema.colProductVariantId: variantId,
                  ProductsSchema.colPriceListId: e.key,
                  ProductsSchema.colPrice: e.value,
                },
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
            for (final addonId in input.addonIds) {
              final price = prices.addonPrices[addonId] ?? 0.0;
              await _db.insert(
                ProductsSchema.tableProductVariantAddon,
                {
                  ProductsSchema.colProductVariantId: variantId,
                  ProductsSchema.colAddonId: addonId,
                  ProductsSchema.colPrice: price,
                },
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
          }
        }
      } else {
        for (final e in input.productPriceListPrices.entries) {
          await _db.insert(
            ProductsSchema.tableProductPriceListPrices,
            {
              ProductsSchema.colProductId: productId,
              ProductsSchema.colPriceListId: e.key,
              ProductsSchema.colPrice: e.value,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      for (final addonId in input.addonIds) {
        await _db.insert(
          ProductsSchema.tableProductAddon,
          {
            ProductsSchema.colProductId: productId,
            ProductsSchema.colAddonId: addonId,
            ProductsSchema.colPrice: 0.0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      return Right(productId);
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.insertFailed(e),
      );
    }
  }

  @override
  Future<Either<OfflineFailure, ProductDetailModel>> getProductById(
    int productId,
  ) async {
    try {
      final productRows = await _db.query(
        ProductsSchema.tableProducts,
        where: '${ProductsSchema.colId} = ?',
        whereArgs: [productId],
      );
      if (productRows.isEmpty) {
        return Left(OfflineFailure.invalidArgument('Product not found'));
      }
      final product = productRows.first;
      final name = product[ProductsSchema.colName] as String? ?? '';
      final nameEn = product[ProductsSchema.colNameEn] as String?;
      final description = product[ProductsSchema.colDescription] as String?;
      final hasVariants =
          (product[ProductsSchema.colHasVariants] as int?) == 1;

      final categoryRows = await _db.query(
        ProductsSchema.tableCategoryProduct,
        columns: [ProductsSchema.colCategoryId],
        where: '${ProductsSchema.colProductId} = ?',
        whereArgs: [productId],
      );
      final categoryIds = categoryRows
          .map((r) => r[ProductsSchema.colCategoryId] as int)
          .toList();

      final addonRows = await _db.query(
        ProductsSchema.tableProductAddon,
        columns: [ProductsSchema.colAddonId],
        where: '${ProductsSchema.colProductId} = ?',
        whereArgs: [productId],
      );
      final addonIds =
          addonRows.map((r) => r[ProductsSchema.colAddonId] as int).toList();

      List<ProductVariableRow> variableRows = [];
      List<VariantPricesRow> variantPricesRows = [];

      if (hasVariants) {
        final varRows = await _db.query(
          ProductsSchema.tableProductVariables,
          where: '${ProductsSchema.colProductId} = ?',
          whereArgs: [productId],
          orderBy: ProductsSchema.colSortOrder,
        );
        final variableValueIds = <List<int>>[];
        for (final vr in varRows) {
          final varId = vr[ProductsSchema.colId] as int;
          final varName =
              vr[ProductsSchema.colVariableName] as String? ?? '';
          final valueRows = await _db.query(
            ProductsSchema.tableProductVariableValues,
            where: '${ProductsSchema.colProductVariableId} = ?',
            whereArgs: [varId],
            orderBy: ProductsSchema.colSortOrder,
          );
          final values = valueRows
              .map((r) => (r[ProductsSchema.colValue] as String?) ?? '')
              .toList();
          final valueIds = valueRows
              .map((r) => r[ProductsSchema.colId] as int)
              .toList();
          variableValueIds.add(valueIds);
          variableRows.add(ProductVariableRow(
            id: varId,
            name: varName,
            values: values.isEmpty ? [''] : values,
          ));
        }

        final variantRows = await _db.query(
          ProductsSchema.tableProductVariants,
          where: '${ProductsSchema.colProductId} = ?',
          whereArgs: [productId],
          orderBy: ProductsSchema.colSortOrder,
        );
        for (final vRow in variantRows) {
          final variantId = vRow[ProductsSchema.colId] as int;
          final basePrice =
              (vRow[ProductsSchema.colBasePrice] as num?)?.toDouble() ?? 0.0;
          final isActive =
              (vRow[ProductsSchema.colIsActive] as int?) == 1;

          final plPriceRows = await _db.query(
            ProductsSchema.tableProductVariantPriceListPrices,
            where: '${ProductsSchema.colProductVariantId} = ?',
            whereArgs: [variantId],
          );
          final priceListPrices = <int, double>{};
          for (final r in plPriceRows) {
            final plId = r[ProductsSchema.colPriceListId] as int?;
            if (plId != null) {
              priceListPrices[plId] =
                  (r[ProductsSchema.colPrice] as num?)?.toDouble() ?? 0.0;
            }
          }

          final addonPriceRows = await _db.query(
            ProductsSchema.tableProductVariantAddon,
            where: '${ProductsSchema.colProductVariantId} = ?',
            whereArgs: [variantId],
          );
          final addonPrices = <int, double>{};
          for (final r in addonPriceRows) {
            final aId = r[ProductsSchema.colAddonId] as int?;
            if (aId != null) {
              addonPrices[aId] =
                  (r[ProductsSchema.colPrice] as num?)?.toDouble() ?? 0.0;
            }
          }

          variantPricesRows.add(VariantPricesRow(
            basePrice: basePrice,
            isActive: isActive,
            priceListPrices: priceListPrices,
            addonPrices: addonPrices,
          ));
        }
      }

      Map<int, double> productPriceListPrices = {};
      if (!hasVariants) {
        final plRows = await _db.query(
          ProductsSchema.tableProductPriceListPrices,
          where: '${ProductsSchema.colProductId} = ?',
          whereArgs: [productId],
        );
        for (final r in plRows) {
          final plId = r[ProductsSchema.colPriceListId] as int?;
          if (plId != null) {
            productPriceListPrices[plId] =
                (r[ProductsSchema.colPrice] as num?)?.toDouble() ?? 0.0;
          }
        }
      }

      return Right(ProductDetailModel(
        id: productId,
        name: name,
        nameEn: nameEn,
        description: description,
        categoryIds: categoryIds,
        hasVariants: hasVariants,
        variableRows: variableRows,
        addonIds: addonIds,
        productPriceListPrices: productPriceListPrices,
        variantPricesRows: variantPricesRows,
      ));
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.queryFailed(e),
      );
    }
  }

  @override
  Future<Either<OfflineFailure, void>> updateProduct(
    ProductDetailModel detail,
  ) async {
    try {
      final now = DateTime.now().toIso8601String();
      final productId = detail.id;

      await _db.update(
        ProductsSchema.tableProducts,
        {
          ProductsSchema.colName: detail.name,
          ProductsSchema.colNameEn: detail.nameEn,
          ProductsSchema.colDescription: detail.description,
          ProductsSchema.colHasVariants: detail.hasVariants ? 1 : 0,
          ProductsSchema.colUpdatedAt: now,
        },
        where: '${ProductsSchema.colId} = ?',
        whereArgs: [productId],
      );

      await _db.delete(
        ProductsSchema.tableCategoryProduct,
        where: '${ProductsSchema.colProductId} = ?',
        whereArgs: [productId],
      );
      for (final catId in detail.categoryIds) {
        await _db.insert(
          ProductsSchema.tableCategoryProduct,
          {
            ProductsSchema.colCategoryId: catId,
            ProductsSchema.colProductId: productId,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await _db.delete(
        ProductsSchema.tableProductAddon,
        where: '${ProductsSchema.colProductId} = ?',
        whereArgs: [productId],
      );
      for (final addonId in detail.addonIds) {
        await _db.insert(
          ProductsSchema.tableProductAddon,
          {
            ProductsSchema.colProductId: productId,
            ProductsSchema.colAddonId: addonId,
            ProductsSchema.colPrice: 0.0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await _deleteProductVariantsAndVariables(productId);

      if (detail.hasVariants && detail.variableRows.isNotEmpty) {
        await _db.delete(
          ProductsSchema.tableProductPriceListPrices,
          where: '${ProductsSchema.colProductId} = ?',
          whereArgs: [productId],
        );
        final variableValueIds = <List<int>>[];
        var sortOrder = 0;
        for (final row in detail.variableRows) {
          final varId = await _db.insert(
            ProductsSchema.tableProductVariables,
            {
              ProductsSchema.colProductId: productId,
              ProductsSchema.colVariableName:
                  row.name.isEmpty ? ' ' : row.name,
              ProductsSchema.colSortOrder: sortOrder++,
              ProductsSchema.colCreatedAt: now,
              ProductsSchema.colUpdatedAt: now,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          final valueIds = <int>[];
          var valueSort = 0;
          for (final v in row.values) {
            if (v.trim().isEmpty) continue;
            final valueId = await _db.insert(
              ProductsSchema.tableProductVariableValues,
              {
                ProductsSchema.colProductVariableId: varId,
                ProductsSchema.colValue: v.trim(),
                ProductsSchema.colSortOrder: valueSort++,
                ProductsSchema.colCreatedAt: now,
                ProductsSchema.colUpdatedAt: now,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            valueIds.add(valueId);
          }
          if (valueIds.isEmpty) continue;
          variableValueIds.add(valueIds);
        }

        if (variableValueIds.isNotEmpty) {
          final combinations = _cartesianProduct(variableValueIds);
          final variantPricesRows = detail.variantPricesRows;
          for (var i = 0; i < combinations.length; i++) {
            final combo = combinations[i];
            final prices = i < variantPricesRows.length
                ? variantPricesRows[i]
                : VariantPricesRow();
            final variantId = await _db.insert(
              ProductsSchema.tableProductVariants,
              {
                ProductsSchema.colProductId: productId,
                ProductsSchema.colBasePrice: prices.basePrice,
                ProductsSchema.colIsActive: prices.isActive ? 1 : 0,
                ProductsSchema.colSortOrder: i,
                ProductsSchema.colCreatedAt: now,
                ProductsSchema.colUpdatedAt: now,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            for (final valueId in combo) {
              await _db.insert(
                ProductsSchema.tableProductVariantValues,
                {
                  ProductsSchema.colProductVariantId: variantId,
                  ProductsSchema.colProductVariableValueId: valueId,
                },
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
            for (final e in prices.priceListPrices.entries) {
              await _db.insert(
                ProductsSchema.tableProductVariantPriceListPrices,
                {
                  ProductsSchema.colProductVariantId: variantId,
                  ProductsSchema.colPriceListId: e.key,
                  ProductsSchema.colPrice: e.value,
                },
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
            for (final addonId in detail.addonIds) {
              final price = prices.addonPrices[addonId] ?? 0.0;
              await _db.insert(
                ProductsSchema.tableProductVariantAddon,
                {
                  ProductsSchema.colProductVariantId: variantId,
                  ProductsSchema.colAddonId: addonId,
                  ProductsSchema.colPrice: price,
                },
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
          }
        }
      } else {
        await _db.delete(
          ProductsSchema.tableProductPriceListPrices,
          where: '${ProductsSchema.colProductId} = ?',
          whereArgs: [productId],
        );
        for (final e in detail.productPriceListPrices.entries) {
          await _db.insert(
            ProductsSchema.tableProductPriceListPrices,
            {
              ProductsSchema.colProductId: productId,
              ProductsSchema.colPriceListId: e.key,
              ProductsSchema.colPrice: e.value,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.updateFailed(e),
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
