import '../../../branches/repos/offline/branches_schema.dart';

/// Schema for delivery_men table (SQLite). Matches MySQL: id, vendor_id, branch_id, name, phone_1, phone_2, address, national_id, created_at, updated_at.
abstract class DeliveryMenSchema {
  DeliveryMenSchema._();

  static const String tableDeliveryMen = 'delivery_men';

  static const String colId = 'id';
  static const String colVendorId = 'vendor_id';
  static const String colBranchId = 'branch_id';
  static const String colName = 'name';
  static const String colPhone1 = 'phone_1';
  static const String colPhone2 = 'phone_2';
  static const String colAddress = 'address';
  static const String colNationalId = 'national_id';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  static const String createTableDeliveryMen =
      '''
    CREATE TABLE $tableDeliveryMen (
      $colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colVendorId INTEGER,
      $colBranchId INTEGER REFERENCES ${BranchesSchema.tableBranches}(${BranchesSchema.colId}),
      $colName TEXT NOT NULL,
      $colPhone1 TEXT,
      $colPhone2 TEXT,
      $colAddress TEXT,
      $colNationalId TEXT,
      $colCreatedAt TEXT,
      $colUpdatedAt TEXT
    )
  ''';

  static const String sqlQuery =
      '''
        SELECT d.${DeliveryMenSchema.colId}, d.${DeliveryMenSchema.colVendorId},
               d.${DeliveryMenSchema.colBranchId}, d.${DeliveryMenSchema.colName},
               d.${DeliveryMenSchema.colPhone1}, d.${DeliveryMenSchema.colPhone2},
               d.${DeliveryMenSchema.colAddress}, d.${DeliveryMenSchema.colNationalId},
               d.${DeliveryMenSchema.colCreatedAt}, d.${DeliveryMenSchema.colUpdatedAt},
               b.${BranchesSchema.colName} AS branch_name
        FROM ${DeliveryMenSchema.tableDeliveryMen} d
        LEFT JOIN ${BranchesSchema.tableBranches} b ON d.${DeliveryMenSchema.colBranchId} = b.${BranchesSchema.colId}
        ORDER BY d.${DeliveryMenSchema.colId}
      ''';
}
