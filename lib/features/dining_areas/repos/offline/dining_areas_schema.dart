import '../../../branches/repos/offline/branches_schema.dart';

/// Schema for dining_areas table (SQLite). id, vendor_id, branch_id, name, created_at, updated_at.
abstract class DiningAreasSchema {
  DiningAreasSchema._();

  static const String tableDiningAreas = 'dining_areas';

  static const String colId = 'id';
  static const String colVendorId = 'vendor_id';
  static const String colBranchId = 'branch_id';
  static const String colName = 'name';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  static const String createTableDiningAreas = '''
    CREATE TABLE $tableDiningAreas (
      $colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colVendorId INTEGER,
      $colBranchId INTEGER REFERENCES ${BranchesSchema.tableBranches}(${BranchesSchema.colId}),
      $colName TEXT NOT NULL,
      $colCreatedAt TEXT,
      $colUpdatedAt TEXT
    )
  ''';

  static const String sqlQuery = '''
    SELECT d.$colId, d.$colVendorId, d.$colBranchId, d.$colName,
           d.$colCreatedAt, d.$colUpdatedAt,
           b.${BranchesSchema.colName} AS branch_name
    FROM $tableDiningAreas d
    LEFT JOIN ${BranchesSchema.tableBranches} b ON d.$colBranchId = b.${BranchesSchema.colId}
    ORDER BY d.$colId
  ''';
}
