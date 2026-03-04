/// Schema for payment_methods table (SQLite). Matches MySQL: id, vendor_id, name, created_by, created_at, updated_at.
abstract class PaymentMethodsSchema {
  PaymentMethodsSchema._();

  static const String tablePaymentMethods = 'payment_methods';

  static const String colId = 'id';
  static const String colVendorId = 'vendor_id';
  static const String colName = 'name';
  static const String colCreatedBy = 'created_by';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  static const String createTablePaymentMethods = '''
    CREATE TABLE $tablePaymentMethods (
      $colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colVendorId INTEGER,
      $colName TEXT NOT NULL,
      $colCreatedBy INTEGER,
      $colCreatedAt TEXT,
      $colUpdatedAt TEXT
    )
  ''';

  static const String sqlQuery = '''
    SELECT $colId, $colVendorId, $colName, $colCreatedBy,
           $colCreatedAt, $colUpdatedAt
    FROM $tablePaymentMethods
    ORDER BY $colId
  ''';
}
