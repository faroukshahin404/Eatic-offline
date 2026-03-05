/// Schema for addons table (SQLite). id, vendor_id, name, default_price, sort_order, created_at, updated_at.
abstract class AddonsSchema {
  AddonsSchema._();

  static const String tableAddons = 'addons';

  static const String colId = 'id';
  static const String colVendorId = 'vendor_id';
  static const String colName = 'name';
  static const String colDefaultPrice = 'default_price';
  static const String colSortOrder = 'sort_order';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  static const String createTableAddons = '''
    CREATE TABLE $tableAddons (
      $colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colVendorId INTEGER,
      $colName TEXT NOT NULL,
      $colDefaultPrice REAL,
      $colSortOrder INTEGER NOT NULL DEFAULT 0,
      $colCreatedAt TEXT,
      $colUpdatedAt TEXT
    )
  ''';

  static const String sqlQuery = '''
    SELECT $colId, $colVendorId, $colName, $colDefaultPrice,
           $colSortOrder, $colCreatedAt, $colUpdatedAt
    FROM $tableAddons
    ORDER BY $colSortOrder, $colId
  ''';
}
