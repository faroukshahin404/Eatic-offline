import '../../../branches/repos/offline/branches_schema.dart';

/// Schema for zones table (SQLite). Matches MySQL: id, vendor_id, branch_id, name, delivery_charge, created_at, updated_at.
abstract class ZonesSchema {
  ZonesSchema._();

  static const String tableZones = 'zones';

  static const String colId = 'id';
  static const String colVendorId = 'vendor_id';
  static const String colBranchId = 'branch_id';
  static const String colName = 'name';
  static const String colDeliveryCharge = 'delivery_charge';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  static const String createTableZones = '''
    CREATE TABLE $tableZones (
      $colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colVendorId INTEGER,
      $colBranchId INTEGER REFERENCES ${BranchesSchema.tableBranches}(${BranchesSchema.colId}),
      $colName TEXT NOT NULL,
      $colDeliveryCharge REAL NOT NULL DEFAULT 0,
      $colCreatedAt TEXT,
      $colUpdatedAt TEXT
    )
  ''';

  static const String sqlQuery = '''
    SELECT z.${ZonesSchema.colId}, z.${ZonesSchema.colVendorId},
           z.${ZonesSchema.colBranchId}, z.${ZonesSchema.colName},
           z.${ZonesSchema.colDeliveryCharge}, z.${ZonesSchema.colCreatedAt},
           z.${ZonesSchema.colUpdatedAt},
           b.${BranchesSchema.colName} AS branch_name
    FROM ${ZonesSchema.tableZones} z
    LEFT JOIN ${BranchesSchema.tableBranches} b ON z.${ZonesSchema.colBranchId} = b.${BranchesSchema.colId}
    ORDER BY z.${ZonesSchema.colId}
  ''';
}
