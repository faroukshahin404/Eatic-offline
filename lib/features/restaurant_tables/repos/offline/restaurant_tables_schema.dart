import '../../../branches/repos/offline/branches_schema.dart';
import '../../../dining_areas/repos/offline/dining_areas_schema.dart';
import '../../../users/repos/offline/users_schema.dart';

/// Schema for restaurant_tables table (SQLite). id, branch_id, dining_area_id, name, created_by, created_at, updated_at.
abstract class RestaurantTablesSchema {
  RestaurantTablesSchema._();

  static const String tableRestaurantTables = 'restaurant_tables';

  static const String colId = 'id';
  static const String colBranchId = 'branch_id';
  static const String colDiningAreaId = 'dining_area_id';
  static const String colName = 'name';
  static const String colIsEmpty = 'is_empty';
  static const String colCreatedBy = 'created_by';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  static const String createTableRestaurantTables = '''
    CREATE TABLE $tableRestaurantTables (
      $colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colBranchId INTEGER REFERENCES ${BranchesSchema.tableBranches}(${BranchesSchema.colId}),
      $colDiningAreaId INTEGER REFERENCES ${DiningAreasSchema.tableDiningAreas}(${DiningAreasSchema.colId}),
      $colName TEXT NOT NULL,
      $colIsEmpty INTEGER NOT NULL DEFAULT 1,
      $colCreatedBy INTEGER REFERENCES ${UsersSchema.tableUsers}(${UsersSchema.colId}),
      $colCreatedAt TEXT,
      $colUpdatedAt TEXT
    )
  ''';

  static const String sqlQuery = '''
    SELECT t.$colId, t.$colBranchId, t.$colDiningAreaId, t.$colName, t.$colIsEmpty,
           t.$colCreatedBy, t.$colCreatedAt, t.$colUpdatedAt,
           b.${BranchesSchema.colName} AS branch_name,
           d.${DiningAreasSchema.colName} AS dining_area_name,
           u.${UsersSchema.colName} AS created_by_name
    FROM $tableRestaurantTables t
    LEFT JOIN ${BranchesSchema.tableBranches} b ON t.$colBranchId = b.${BranchesSchema.colId}
    LEFT JOIN ${DiningAreasSchema.tableDiningAreas} d ON t.$colDiningAreaId = d.${DiningAreasSchema.colId}
    LEFT JOIN ${UsersSchema.tableUsers} u ON t.$colCreatedBy = u.${UsersSchema.colId}
    ORDER BY t.$colId
  ''';

  /// Same as [sqlQuery] with WHERE t.$colBranchId = ?. Use with rawQuery(..., [branchId]).
  static const String sqlQueryByBranchId = '''
    SELECT t.$colId, t.$colBranchId, t.$colDiningAreaId, t.$colName, t.$colIsEmpty,
           t.$colCreatedBy, t.$colCreatedAt, t.$colUpdatedAt,
           b.${BranchesSchema.colName} AS branch_name,
           d.${DiningAreasSchema.colName} AS dining_area_name,
           u.${UsersSchema.colName} AS created_by_name
    FROM $tableRestaurantTables t
    LEFT JOIN ${BranchesSchema.tableBranches} b ON t.$colBranchId = b.${BranchesSchema.colId}
    LEFT JOIN ${DiningAreasSchema.tableDiningAreas} d ON t.$colDiningAreaId = d.${DiningAreasSchema.colId}
    LEFT JOIN ${UsersSchema.tableUsers} u ON t.$colCreatedBy = u.${UsersSchema.colId}
    WHERE t.$colBranchId = ?
    ORDER BY t.$colId
  ''';
}
