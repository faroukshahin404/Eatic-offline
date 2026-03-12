import '../../../../features/addons/repos/offline/addons_schema.dart';
import '../../../../features/categories/repos/offline/categories_schema.dart';
import '../../../../features/price_lists/repos/offline/price_lists_schema.dart';

/// Product-related table schemas for SQLite (products, category_product, product_variables, etc.).
abstract class ProductsSchema {
  ProductsSchema._();

  static const String tableProducts = 'products';
  static const String colId = 'id';
  static const String colVendorId = 'vendor_id';
  static const String colName = 'name';
  static const String colNameEn = 'name_en';
  static const String colDescription = 'description';
  static const String colImage = 'image';
  static const String colDefaultPrice = 'default_price';
  static const String colHasVariants = 'has_variants';
  static const String colSortOrder = 'sort_order';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  static const String createTableProducts = '''
    CREATE TABLE $tableProducts (
      $colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colVendorId INTEGER,
      $colName TEXT NOT NULL,
      $colNameEn TEXT,
      $colDescription TEXT,
      $colImage TEXT,
      $colDefaultPrice REAL,
      $colHasVariants INTEGER NOT NULL DEFAULT 0,
      $colSortOrder INTEGER NOT NULL DEFAULT 0,
      $colCreatedAt TEXT,
      $colUpdatedAt TEXT
    )
  ''';

  static const String tableCategoryProduct = 'category_product';
  static const String colCategoryId = 'category_id';
  static const String colProductId = 'product_id';

  static const String createTableCategoryProduct = '''
    CREATE TABLE $tableCategoryProduct (
      $colCategoryId INTEGER NOT NULL REFERENCES ${CategoriesSchema.tableCategories}(${CategoriesSchema.colId}),
      $colProductId INTEGER NOT NULL REFERENCES $tableProducts($colId),
      PRIMARY KEY ($colCategoryId, $colProductId)
    )
  ''';

  static const String tableProductVariables = 'product_variables';
  static const String colProductVariableId = 'product_variable_id';
  static const String colVariableName = 'name';

  static const String createTableProductVariables = '''
    CREATE TABLE $tableProductVariables (
      $colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colProductId INTEGER NOT NULL REFERENCES $tableProducts($colId),
      $colVariableName TEXT NOT NULL,
      $colSortOrder INTEGER NOT NULL DEFAULT 0,
      $colCreatedAt TEXT,
      $colUpdatedAt TEXT
    )
  ''';

  static const String tableProductVariableValues = 'product_variable_values';
  static const String colProductVariableValueId = 'product_variable_value_id';
  static const String colValue = 'value';

  static const String createTableProductVariableValues = '''
    CREATE TABLE $tableProductVariableValues (
      $colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colProductVariableId INTEGER NOT NULL REFERENCES $tableProductVariables($colId),
      $colValue TEXT NOT NULL,
      $colSortOrder INTEGER NOT NULL DEFAULT 0,
      $colCreatedAt TEXT,
      $colUpdatedAt TEXT
    )
  ''';

  static const String tableProductVariants = 'product_variants';
  static const String colProductVariantId = 'product_variant_id';
  static const String colBasePrice = 'base_price';
  static const String colIsActive = 'is_active';

  static const String createTableProductVariants = '''
    CREATE TABLE $tableProductVariants (
      $colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colProductId INTEGER NOT NULL REFERENCES $tableProducts($colId),
      $colBasePrice REAL NOT NULL DEFAULT 0,
      $colIsActive INTEGER NOT NULL DEFAULT 1,
      $colSortOrder INTEGER NOT NULL DEFAULT 0,
      $colCreatedAt TEXT,
      $colUpdatedAt TEXT
    )
  ''';

  static const String tableProductVariantValues = 'product_variant_values';

  static const String createTableProductVariantValues = '''
    CREATE TABLE $tableProductVariantValues (
      $colProductVariantId INTEGER NOT NULL REFERENCES $tableProductVariants($colId),
      $colProductVariableValueId INTEGER NOT NULL REFERENCES $tableProductVariableValues($colId),
      PRIMARY KEY ($colProductVariantId, $colProductVariableValueId)
    )
  ''';

  static const String tableProductAddon = 'product_addon';
  static const String colAddonId = 'addon_id';
  static const String colPrice = 'price';

  static const String createTableProductAddon = '''
    CREATE TABLE $tableProductAddon (
      $colProductId INTEGER NOT NULL REFERENCES $tableProducts($colId),
      $colAddonId INTEGER NOT NULL REFERENCES ${AddonsSchema.tableAddons}(${AddonsSchema.colId}),
      $colPrice REAL NOT NULL DEFAULT 0,
      PRIMARY KEY ($colProductId, $colAddonId)
    )
  ''';

  static const String tableProductVariantAddon = 'product_variant_addon';

  static const String createTableProductVariantAddon = '''
    CREATE TABLE $tableProductVariantAddon (
      $colProductVariantId INTEGER NOT NULL REFERENCES $tableProductVariants($colId),
      $colAddonId INTEGER NOT NULL REFERENCES ${AddonsSchema.tableAddons}(${AddonsSchema.colId}),
      $colPrice REAL NOT NULL DEFAULT 0,
      PRIMARY KEY ($colProductVariantId, $colAddonId)
    )
  ''';

  static const String tableProductPriceListPrices = 'product_price_list_prices';
  static const String colPriceListId = 'price_list_id';

  static const String createTableProductPriceListPrices = '''
    CREATE TABLE $tableProductPriceListPrices (
      $colProductId INTEGER NOT NULL REFERENCES $tableProducts($colId),
      $colPriceListId INTEGER NOT NULL REFERENCES ${PriceListsSchema.tablePriceLists}(${PriceListsSchema.colId}),
      $colPrice REAL NOT NULL DEFAULT 0,
      PRIMARY KEY ($colProductId, $colPriceListId)
    )
  ''';

  static const String tableProductVariantPriceListPrices =
      'product_variant_price_list_prices';

  static const String createTableProductVariantPriceListPrices = '''
    CREATE TABLE $tableProductVariantPriceListPrices (
      $colProductVariantId INTEGER NOT NULL REFERENCES $tableProductVariants($colId),
      $colPriceListId INTEGER NOT NULL REFERENCES ${PriceListsSchema.tablePriceLists}(${PriceListsSchema.colId}),
      $colPrice REAL NOT NULL DEFAULT 0,
      PRIMARY KEY ($colProductVariantId, $colPriceListId)
    )
  ''';
}
