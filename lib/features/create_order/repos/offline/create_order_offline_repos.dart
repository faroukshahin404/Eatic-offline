import 'package:dartz/dartz.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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

  /// Fetches product-level price list prices (for products without variants).
  /// Returns map of price_list_id -> price. Empty if product has variants or no rows.
  DbCall<Map<int, double>> getProductPriceListPrices(int productId);

  /// Fetches all variants for a product (with variable labels and value IDs).
  DbCall<List<CreateOrderVariantModel>> getVariantsByProductId(int productId);

  /// Fetches variable groups (name + options) for a product; used for column-based variant UI.
  DbCall<List<CreateOrderVariableGroup>> getProductVariableGroups(int productId);

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
  Future<Either<OfflineFailure, Map<int, double>>> getProductPriceListPrices(
    int productId,
  ) async {
    try {
      final rows = await _db.query(
        ProductsSchema.tableProductPriceListPrices,
        where: '${ProductsSchema.colProductId} = ?',
        whereArgs: [productId],
      );
      final map = <int, double>{};
      for (final r in rows) {
        final plId = r[ProductsSchema.colPriceListId] as int?;
        if (plId != null) {
          map[plId] = (r[ProductsSchema.colPrice] as num?)?.toDouble() ?? 0.0;
        }
      }
      return Right(map);
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
        final valueIds = await _getVariantValueIds(variantId);
        final priceListPrices = await _getVariantPriceListPrices(variantId);
        final addonPrices = await _getVariantAddonPrices(variantId);
        list.add(CreateOrderVariantModel(
          id: variantId,
          productId: productId,
          basePrice: basePrice,
          isActive: isActive,
          sortOrder: sortOrder,
          variableLabels: labels,
          valueIds: valueIds,
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
    final rows = await _getVariantValueRows(variantId);
    return rows
        .map((r) => (r[ProductsSchema.colValue] as String?) ?? '')
        .toList();
  }

  /// Returns variable value IDs for a variant, in variable then value sort order.
  Future<List<int>> _getVariantValueIds(int variantId) async {
    final rows = await _getVariantValueRows(variantId);
    return rows
        .map((r) => r[ProductsSchema.colId] as int? ?? 0)
        .where((id) => id != 0)
        .toList();
  }

  /// Shared query for variant values (id + value text), ordered by variable then value sort.
  Future<List<Map<String, dynamic>>> _getVariantValueRows(int variantId) async {
    return _db.rawQuery('''
      SELECT pvval.${ProductsSchema.colId}, pvval.${ProductsSchema.colValue}
      FROM ${ProductsSchema.tableProductVariantValues} pvv
      INNER JOIN ${ProductsSchema.tableProductVariableValues} pvval
        ON pvval.${ProductsSchema.colId} = pvv.${ProductsSchema.colProductVariableValueId}
      INNER JOIN ${ProductsSchema.tableProductVariables} pvar
        ON pvar.${ProductsSchema.colId} = pvval.${ProductsSchema.colProductVariableId}
      WHERE pvv.${ProductsSchema.colProductVariantId} = ?
      ORDER BY pvar.${ProductsSchema.colSortOrder}, pvval.${ProductsSchema.colSortOrder}
    ''', [variantId]);
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
  Future<Either<OfflineFailure, List<CreateOrderVariableGroup>>>
      getProductVariableGroups(int productId) async {
    try {
      final varRows = await _db.query(
        ProductsSchema.tableProductVariables,
        where: '${ProductsSchema.colProductId} = ?',
        whereArgs: [productId],
        orderBy: '${ProductsSchema.colSortOrder} ASC, ${ProductsSchema.colId} ASC',
      );
      final groups = <CreateOrderVariableGroup>[];
      for (final vr in varRows) {
        final varId = vr[ProductsSchema.colId] as int;
        final varName =
            (vr[ProductsSchema.colVariableName] as String?)?.trim() ?? '';
        final sortOrder = vr[ProductsSchema.colSortOrder] as int? ?? 0;
        final valueRows = await _db.query(
          ProductsSchema.tableProductVariableValues,
          where: '${ProductsSchema.colProductVariableId} = ?',
          whereArgs: [varId],
          orderBy: '${ProductsSchema.colSortOrder} ASC',
        );
        final options = valueRows
            .map((r) => CreateOrderVariableOption(
                  valueId: r[ProductsSchema.colId] as int,
                  label: (r[ProductsSchema.colValue] as String?) ?? '',
                ))
            .toList();
        if (options.isNotEmpty) {
          groups.add(CreateOrderVariableGroup(
            variableId: varId,
            name: varName.isEmpty ? ' ' : varName,
            sortOrder: sortOrder,
            options: options,
          ));
        }
      }
      return Right(groups);
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.queryFailed(e),
      );
    }
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
