/// Schema for currencies table (SQLite). Matches MySQL: id, vendor_id, name, code, symbol, created_at, updated_at.
abstract class CurrenciesSchema {
  CurrenciesSchema._();

  static const String tableCurrencies = 'currencies';

  static const String colId = 'id';
  static const String colVendorId = 'vendor_id';
  static const String colName = 'name';
  static const String colCode = 'code';
  static const String colSymbol = 'symbol';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  static const String createTableCurrencies =
      '''
    CREATE TABLE $tableCurrencies (
      $colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colVendorId INTEGER,
      $colName TEXT NOT NULL,
      $colCode TEXT NOT NULL,
      $colSymbol TEXT,
      $colCreatedAt TEXT,
      $colUpdatedAt TEXT
    )
  ''';

  static const String sqlQuery =
      '''
    SELECT $colId, $colVendorId, $colName, $colCode, $colSymbol,
           $colCreatedAt, $colUpdatedAt
    FROM $tableCurrencies
    ORDER BY $colId
  ''';
}
