import '../../../users/model/user_model.dart';
import '../../../users/repos/offline/users_schema.dart';

/// Schema for branches table (SQLite). Maps from MySQL: id, name, created_at, updated_at, vendor_id, created_by.
abstract class BranchesSchema {
  BranchesSchema._();

  static const String tableBranches = 'branches';

  static const String colId = 'id';
  static const String colName = 'name';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
  static const String colVendorId = 'vendor_id';
  /// User id of creator (FK to users.id; use [UserModel] when loading with join).
  static const String colCreatedBy = 'created_by';

  static const String createTableBranches = '''
    CREATE TABLE $tableBranches (
      $colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colName TEXT NOT NULL,
      $colCreatedAt TEXT,
      $colUpdatedAt TEXT,
      $colVendorId INTEGER,
      $colCreatedBy INTEGER REFERENCES ${UsersSchema.tableUsers}(${UsersSchema.colId})
    )
  ''';
}
