import '../../../currencies/repos/offline/currencies_schema.dart';

/// Schema for price_lists table (SQLite). id, vendor_id, currency_id, name, created_at, updated_at.
abstract class PriceListsSchema {
  PriceListsSchema._();

  static const String tablePriceLists = 'price_lists';

  static const String colId = 'id';
  static const String colVendorId = 'vendor_id';
  static const String colCurrencyId = 'currency_id';
  static const String colName = 'name';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  static const String createTablePriceLists = '''
    CREATE TABLE $tablePriceLists (
      $colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colVendorId INTEGER,
      $colCurrencyId INTEGER NOT NULL REFERENCES ${CurrenciesSchema.tableCurrencies}(${CurrenciesSchema.colId}),
      $colName TEXT NOT NULL,
      $colCreatedAt TEXT,
      $colUpdatedAt TEXT
    )
  ''';

  static const String sqlQuery = '''
    SELECT p.$colId, p.$colVendorId, p.$colCurrencyId, p.$colName,
           p.$colCreatedAt, p.$colUpdatedAt,
           c.${CurrenciesSchema.colName} AS currency_name
    FROM $tablePriceLists p
    LEFT JOIN ${CurrenciesSchema.tableCurrencies} c ON p.$colCurrencyId = c.${CurrenciesSchema.colId}
    ORDER BY p.$colId
  ''';
}
