import '../../../users/repos/offline/users_schema.dart';

/// Schema for custody table (SQLite).
abstract class CustodySchema {
  CustodySchema._();

  static const String tableCustody = 'custody';

  static const String colId = 'id';
  static const String colTotalWhenCreate = 'total_when_create';
  static const String colCreatedAt = 'created_at';
  static const String colShiftStartedAt = 'shift_started_at';
  static const String colCreatedBy = 'created_by';
  static const String colIsClosed = 'is_closed';
  static const String colClosedBy = 'closed_by';
  static const String colShiftEndedAt = 'shift_ended_at';
  static const String colTotalWhenClose = 'total_when_close';

  static const String createTableCustody = '''
    CREATE TABLE $tableCustody (
      $colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colTotalWhenCreate REAL NOT NULL DEFAULT 0,
      $colCreatedAt TEXT,
      $colShiftStartedAt TEXT,
      $colCreatedBy INTEGER REFERENCES ${UsersSchema.tableUsers}(${UsersSchema.colId}),
      $colIsClosed INTEGER NOT NULL DEFAULT 0,
      $colClosedBy INTEGER REFERENCES ${UsersSchema.tableUsers}(${UsersSchema.colId}),
      $colShiftEndedAt TEXT,
      $colTotalWhenClose REAL
    )
  ''';
}
