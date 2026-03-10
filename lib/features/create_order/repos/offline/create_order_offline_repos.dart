import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../../add_new_product/model/product_model.dart';
import '../../../add_new_product/repos/offline/products_schema.dart';
import '../../../addons/repos/offline/addons_schema.dart';
import '../../model/create_order_addon_model.dart';
import '../../model/create_order_variant_model.dart';

abstract class CreateOrderOfflineRepository {
  /// Fetches a product by id; returns null if not found.
  DbCall<ProductModel?> getProductById(int productId);

  /// Fetches all variants for a product (with variable labels for display).
  DbCall<List<CreateOrderVariantModel>> getVariantsByProductId(int productId);

  /// Fetches addons linked to a product (with product-level price).
  DbCall<List<CreateOrderAddonModel>> getAddonsByProductId(int productId);
}

class CreateOrderOfflineRepoImpl implements CreateOrderOfflineRepository {
  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, ProductModel?>> getProductById(
    int productId,
  ) async {
    try {
      final rows = await _db.query(
        ProductsSchema.tableProducts,
        where: '${ProductsSchema.colId} = ?',
        whereArgs: [productId],
      );
      if (rows.isEmpty) return const Right(null);
      return Right(ProductModel.fromMap(rows.first));
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.queryFailed(e),
      );
    }
  }

  @override
  Future<Either<OfflineFailure, List<CreateOrderVariantModel>>>
      getVariantsByProductId(int productId) async {
    try {
      final variantRows = await _db.query(
        ProductsSchema.tableProductVariants,
        where: '${ProductsSchema.colProductId} = ?',
        whereArgs: [productId],
        orderBy: '${ProductsSchema.colSortOrder} ASC, ${ProductsSchema.colId} ASC',
      );
      final list = <CreateOrderVariantModel>[];
      for (final v in variantRows) {
        final variantId = v[ProductsSchema.colId] as int;
        final basePrice =
            (v[ProductsSchema.colBasePrice] as num?)?.toDouble() ?? 0.0;
        final isActive = (v[ProductsSchema.colIsActive] as int?) == 1;
        final sortOrder = v[ProductsSchema.colSortOrder] as int? ?? 0;

        final labels = await _getVariantVariableLabels(variantId);
        final priceListPrices = await _getVariantPriceListPrices(variantId);
        final addonPrices = await _getVariantAddonPrices(variantId);
        list.add(CreateOrderVariantModel(
          id: variantId,
          productId: productId,
          basePrice: basePrice,
          isActive: isActive,
          sortOrder: sortOrder,
          variableLabels: labels,
          priceListPrices: priceListPrices,
          addonPrices: addonPrices,
        ));
      }
      return Right(list);
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.queryFailed(e),
      );
    }
  }

  /// Returns variable value labels for a variant, ordered by variable then value sort order.
  Future<List<String>> _getVariantVariableLabels(int variantId) async {
    final rows = await _db.rawQuery('''
      SELECT pvval.${ProductsSchema.colValue}
      FROM ${ProductsSchema.tableProductVariantValues} pvv
      INNER JOIN ${ProductsSchema.tableProductVariableValues} pvval
        ON pvval.${ProductsSchema.colId} = pvv.${ProductsSchema.colProductVariableValueId}
      INNER JOIN ${ProductsSchema.tableProductVariables} pvar
        ON pvar.${ProductsSchema.colId} = pvval.${ProductsSchema.colProductVariableId}
      WHERE pvv.${ProductsSchema.colProductVariantId} = ?
      ORDER BY pvar.${ProductsSchema.colSortOrder}, pvval.${ProductsSchema.colSortOrder}
    ''', [variantId]);
    return rows
        .map((r) => (r[ProductsSchema.colValue] as String?) ?? '')
        .toList();
  }

  /// Returns price list id -> price for a variant.
  Future<Map<int, double>> _getVariantPriceListPrices(int variantId) async {
    final rows = await _db.query(
      ProductsSchema.tableProductVariantPriceListPrices,
      where: '${ProductsSchema.colProductVariantId} = ?',
      whereArgs: [variantId],
    );
    final map = <int, double>{};
    for (final r in rows) {
      final plId = r[ProductsSchema.colPriceListId] as int?;
      if (plId != null) {
        map[plId] = (r[ProductsSchema.colPrice] as num?)?.toDouble() ?? 0.0;
      }
    }
    return map;
  }

  /// Returns addon id -> price for a variant.
  Future<Map<int, double>> _getVariantAddonPrices(int variantId) async {
    final rows = await _db.query(
      ProductsSchema.tableProductVariantAddon,
      where: '${ProductsSchema.colProductVariantId} = ?',
      whereArgs: [variantId],
    );
    final map = <int, double>{};
    for (final r in rows) {
      final addonId = r[ProductsSchema.colAddonId] as int?;
      if (addonId != null) {
        map[addonId] = (r[ProductsSchema.colPrice] as num?)?.toDouble() ?? 0.0;
      }
    }
    return map;
  }

  @override
  Future<Either<OfflineFailure, List<CreateOrderAddonModel>>>
      getAddonsByProductId(int productId) async {
    try {
      final rows = await _db.rawQuery('''
        SELECT a.${AddonsSchema.colId}, a.${AddonsSchema.colName}, pa.${ProductsSchema.colPrice}
        FROM ${ProductsSchema.tableProductAddon} pa
        INNER JOIN ${AddonsSchema.tableAddons} a ON a.${AddonsSchema.colId} = pa.${ProductsSchema.colAddonId}
        WHERE pa.${ProductsSchema.colProductId} = ?
        ORDER BY a.${AddonsSchema.colSortOrder}, a.${AddonsSchema.colId}
      ''', [productId]);
      final list = rows
          .map((r) => CreateOrderAddonModel(
                addonId: r[AddonsSchema.colId] as int,
                name: (r[AddonsSchema.colName] as String?) ?? '',
                price: (r[ProductsSchema.colPrice] as num?)?.toDouble() ?? 0.0,
              ))
          .toList();
      return Right(list);
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.queryFailed(e),
      );
    }
  }
}
