import '../../core_repos/offline/roles/roles_schema.dart';
import '../../../../features/branches/repos/offline/branches_schema.dart';
import '../../../../features/users/repos/offline/users_schema.dart';
import '../../../../features/deliveries/repos/offline/deliveries_schema.dart';
import '../../../../features/zones/repos/offline/zones_schema.dart';
import '../../../../features/currencies/repos/offline/currencies_schema.dart';
import '../../../../features/payment_methods/repos/offline/payment_methods_schema.dart';
import '../../../../features/dining_areas/repos/offline/dining_areas_schema.dart';
import '../../../../features/restaurant_tables/repos/offline/restaurant_tables_schema.dart';
import '../../../../features/categories/repos/offline/categories_schema.dart';
import '../../../../features/addons/repos/offline/addons_schema.dart';
import '../../../../features/price_lists/repos/offline/price_lists_schema.dart';
import '../../../../features/add_new_product/repos/offline/products_schema.dart';
import '../../../../features/custody/repos/offline/custody_schema.dart';

/// Central configuration for SQLite database.
/// Aggregates createTableStatements from core/feature models. Roles first, then users, branches, delivery_men, zones, currencies.
abstract class DatabaseUtils {
  DatabaseUtils._();

  static const String databaseName = 'eatic.db';
  static const int databaseVersion = 13;

  /// Run in order: roles, users, branches, ..., price_lists, products, category_product, product_variables, product_variable_values, product_variants, product_variant_values, product_addon, product_variant_addon, product_price_list_prices, product_variant_price_list_prices.
  static const List<String> createTableStatements = [
    RolesStatement.createTableRoles,
    UsersSchema.createTableUsers,
    BranchesSchema.createTableBranches,
    DeliveryMenSchema.createTableDeliveryMen,
    ZonesSchema.createTableZones,
    CurrenciesSchema.createTableCurrencies,
    PaymentMethodsSchema.createTablePaymentMethods,
    DiningAreasSchema.createTableDiningAreas,
    RestaurantTablesSchema.createTableRestaurantTables,
    CategoriesSchema.createTableCategories,
    AddonsSchema.createTableAddons,
    PriceListsSchema.createTablePriceLists,
    ProductsSchema.createTableProducts,
    ProductsSchema.createTableCategoryProduct,
    ProductsSchema.createTableProductVariables,
    ProductsSchema.createTableProductVariableValues,
    ProductsSchema.createTableProductVariants,
    ProductsSchema.createTableProductVariantValues,
    ProductsSchema.createTableProductAddon,
    ProductsSchema.createTableProductVariantAddon,
    ProductsSchema.createTableProductPriceListPrices,
    ProductsSchema.createTableProductVariantPriceListPrices,
    CustodySchema.createTableCustody,
  ];

  /// Run after createTableStatements in onCreate (e.g. seed default roles).
  static List<String> get seedStatements => RolesStatement.seedStatements;

  /// Migrations for existing DBs that were created before branches table existed.
  static List<String> get migrationFrom1To2 => [
        BranchesSchema.createTableBranches,
      ];

  /// Migrations for existing DBs that were created before delivery_men table existed.
  static List<String> get migrationFrom2To3 => [
        DeliveryMenSchema.createTableDeliveryMen,
      ];

  /// Migrations for existing DBs that were created before zones table existed.
  static List<String> get migrationFrom3To4 => [
        ZonesSchema.createTableZones,
      ];

  /// Migrations for existing DBs that were created before currencies table existed.
  static List<String> get migrationFrom4To5 => [
        CurrenciesSchema.createTableCurrencies,
      ];

  /// Migrations for existing DBs that were created before payment_methods table existed.
  static List<String> get migrationFrom5To6 => [
        PaymentMethodsSchema.createTablePaymentMethods,
      ];

  /// Migrations for existing DBs that were created before dining_areas table existed.
  static List<String> get migrationFrom6To7 => [
        DiningAreasSchema.createTableDiningAreas,
      ];

  /// Migrations for existing DBs that were created before restaurant_tables table existed.
  static List<String> get migrationFrom7To8 => [
        RestaurantTablesSchema.createTableRestaurantTables,
      ];

  /// Migrations for existing DBs that were created before categories table existed.
  static List<String> get migrationFrom8To9 => [
        CategoriesSchema.createTableCategories,
      ];

  /// Migrations for existing DBs that were created before addons table existed.
  static List<String> get migrationFrom9To10 => [
        AddonsSchema.createTableAddons,
      ];

  /// Migrations for existing DBs that were created before price_lists table existed.
  static List<String> get migrationFrom10To11 => [
        PriceListsSchema.createTablePriceLists,
      ];

  /// Migrations for existing DBs that were created before product tables existed.
  static List<String> get migrationFrom11To12 => [
        ProductsSchema.createTableProducts,
        ProductsSchema.createTableCategoryProduct,
        ProductsSchema.createTableProductVariables,
        ProductsSchema.createTableProductVariableValues,
        ProductsSchema.createTableProductVariants,
        ProductsSchema.createTableProductVariantValues,
        ProductsSchema.createTableProductAddon,
        ProductsSchema.createTableProductVariantAddon,
        ProductsSchema.createTableProductPriceListPrices,
        ProductsSchema.createTableProductVariantPriceListPrices,
      ];

  static List<String> get migrationFrom12To13 => [
        CustodySchema.createTableCustody,
      ];
}
