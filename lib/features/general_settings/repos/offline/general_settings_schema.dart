/// Schema for app_settings table (SQLite).
/// Stores generic key/value settings with audit columns.
abstract class GeneralSettingsSchema {
  GeneralSettingsSchema._();

  static const String tableAppSettings = 'app_settings';

  static const String colId = 'id';
  static const String colKey = 'setting_key';
  static const String colValue = 'setting_value';
  static const String colCreatedBy = 'created_by';
  static const String colUpdatedBy = 'updated_by';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  static const String createTableAppSettings = '''
    CREATE TABLE $tableAppSettings (
      $colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colKey TEXT NOT NULL UNIQUE,
      $colValue TEXT,
      $colCreatedBy INTEGER,
      $colUpdatedBy INTEGER,
      $colCreatedAt TEXT,
      $colUpdatedAt TEXT
    )
  ''';
}
