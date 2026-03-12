import '../../../../core/core_repos/offline/roles/roles_schema.dart';

abstract class UsersSchema {
  UsersSchema._();

  static const String tableUsers = 'users';

  static const String colId = 'id';
  static const String colCode = 'code';
  static const String colName = 'name';
  static const String colPassword = 'password';
  static const String colRoleId = 'role_id';
  static const String colBranchId = 'branch_id';
  static const String colCreatedBy = 'created_by';
  static const String colUpdatedBy = 'updated_by';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  static const String createTableUsers =
      '''
    CREATE TABLE $tableUsers (
      $colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colCode TEXT UNIQUE NOT NULL,
      $colName TEXT,
      $colPassword TEXT,
      $colRoleId INTEGER NOT NULL REFERENCES ${RolesStatement.tableRoles}(${RolesStatement.colId}),
      $colBranchId INTEGER REFERENCES branches(id),
      $colCreatedBy INTEGER REFERENCES $tableUsers($colId),
      $colUpdatedBy INTEGER REFERENCES $tableUsers($colId),
      $colCreatedAt TEXT NOT NULL,
      $colUpdatedAt TEXT NOT NULL
    )
  ''';
}
