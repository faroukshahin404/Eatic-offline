import 'dart:io' show Platform;

import 'package:dartz/dartz.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../error/offline_error.dart';
import 'database_utils.dart';

typedef DbCall<T> = Future<Either<OfflineFailure, T>>;

class DatabaseService {
  Database? _database;
  bool _isInitialized = false;

  static final DatabaseService _instance = DatabaseService._();
  factory DatabaseService() => _instance;

  DatabaseService._();

  /// Whether the database has been opened.
  bool get isInitialized => _isInitialized;

  /// Initializes the database. Call once during app startup (e.g. in [AppUtils.appSetup]).
  Future<void> init() async {
    if (_isInitialized) return;

    // Use FFI implementation on desktop (Windows, Linux, macOS) for SQLite support.
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DatabaseUtils.databaseName);

    _database = await openDatabase(
      path,
      version: DatabaseUtils.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    _isInitialized = true;
  }

  /// Returns the database instance. Throws if [init] has not been called.
  Database get database {
    if (_database == null || !_isInitialized) {
      throw StateError(
        'DatabaseService not initialized. Call init() before accessing database.',
      );
    }
    return _database!;
  }

  /// Closes the database. Use for testing or app teardown.
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _isInitialized = false;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    for (final sql in DatabaseUtils.createTableStatements) {
      await db.execute(sql);
    }
    for (final sql in DatabaseUtils.seedStatements) {
      await db.execute(sql);
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      for (final sql in DatabaseUtils.migrationFrom1To2) {
        await db.execute(sql);
      }
    }
    if (oldVersion < 3) {
      for (final sql in DatabaseUtils.migrationFrom2To3) {
        await db.execute(sql);
      }
    }
    if (oldVersion < 4) {
      for (final sql in DatabaseUtils.migrationFrom3To4) {
        await db.execute(sql);
      }
    }
    if (oldVersion < 5) {
      for (final sql in DatabaseUtils.migrationFrom4To5) {
        await db.execute(sql);
      }
    }
    if (oldVersion < 6) {
      for (final sql in DatabaseUtils.migrationFrom5To6) {
        await db.execute(sql);
      }
    }
    if (oldVersion < 7) {
      for (final sql in DatabaseUtils.migrationFrom6To7) {
        await db.execute(sql);
      }
    }
    if (oldVersion < 8) {
      for (final sql in DatabaseUtils.migrationFrom7To8) {
        await db.execute(sql);
      }
    }
    if (oldVersion < 9) {
      for (final sql in DatabaseUtils.migrationFrom8To9) {
        await db.execute(sql);
      }
    }
    if (oldVersion < 10) {
      for (final sql in DatabaseUtils.migrationFrom9To10) {
        await db.execute(sql);
      }
    }
    if (oldVersion < 11) {
      for (final sql in DatabaseUtils.migrationFrom10To11) {
        await db.execute(sql);
      }
    }
    if (oldVersion < 12) {
      for (final sql in DatabaseUtils.migrationFrom11To12) {
        await db.execute(sql);
      }
    }
    if (oldVersion < 13) {
      for (final sql in DatabaseUtils.migrationFrom12To13) {
        await db.execute(sql);
      }
    }
    if (oldVersion < 14) {
      for (final sql in DatabaseUtils.migrationFrom13To14) {
        await db.execute(sql);
      }
    }
    if (oldVersion < 15) {
      for (final sql in DatabaseUtils.migrationFrom14To15) {
        await db.execute(sql);
      }
    }
    if (oldVersion < 16) {
      for (final sql in DatabaseUtils.migrationFrom15To16) {
        await db.execute(sql);
      }
    }
  }
}
