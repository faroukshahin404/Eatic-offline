/// Roles table schema and create/seed statements for SQLite.
/// Roles must be created before the users table (users.role_id references roles.id).
abstract class RolesStatement {
  RolesStatement._();

  static const String tableRoles = 'roles';

  static const String colId = 'id';
  static const String colName = 'name';

  /// Role names used across the app (admin, supervisor, cashier, waiter).
  static const List<String> roleNames = ['admin', 'supervisor', 'cashier', 'waiter'];

  static const String createTableRoles = '''
    CREATE TABLE $tableRoles (
      $colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colName TEXT UNIQUE NOT NULL
    )
  ''';

  static const List<String> createTableStatements = [createTableRoles];

  /// Inserts default roles. Execute after [createTableStatements] in onCreate.
  static List<String> get seedStatements => [
        for (final name in roleNames)
          "INSERT INTO $tableRoles ($colName) VALUES ('$name')",
      ];
}
