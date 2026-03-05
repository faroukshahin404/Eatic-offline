/// Schema for categories table (SQLite). id, vendor_id, name, parent_id (self-ref), created_at, updated_at.
abstract class CategoriesSchema {
  CategoriesSchema._();

  static const String tableCategories = 'categories';

  static const String colId = 'id';
  static const String colVendorId = 'vendor_id';
  static const String colName = 'name';
  static const String colParentId = 'parent_id';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  static const String createTableCategories = '''
    CREATE TABLE $tableCategories (
      $colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colVendorId INTEGER,
      $colName TEXT NOT NULL,
      $colParentId INTEGER REFERENCES $tableCategories($colId),
      $colCreatedAt TEXT,
      $colUpdatedAt TEXT
    )
  ''';

  /// getAll with parent category name (parent_id -> parent.name AS parent_name).
  static const String sqlQuery = '''
    SELECT c.$colId, c.$colVendorId, c.$colName, c.$colParentId,
           c.$colCreatedAt, c.$colUpdatedAt,
           p.$colName AS parent_name
    FROM $tableCategories c
    LEFT JOIN $tableCategories p ON c.$colParentId = p.$colId
    ORDER BY c.$colId
  ''';
}
