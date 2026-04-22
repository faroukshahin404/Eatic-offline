import 'package:dartz/dartz.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../core/data/sqLite/database_service.dart';
import '../../../../core/error/offline_error.dart';
import '../../../../services_locator/service_locator.dart';
import '../../model/general_setting_model.dart';
import 'general_settings_schema.dart';

abstract class GeneralSettingsOfflineRepository {
  DbCall<Map<String, String>> getAllAsMap();
  DbCall<void> upsertMany({
    required Map<String, String> settings,
    required int? userId,
  });
}

class GeneralSettingsOfflineRepoImpl
    implements GeneralSettingsOfflineRepository {
  Database get _db => getIt<DatabaseService>().database;

  @override
  Future<Either<OfflineFailure, Map<String, String>>> getAllAsMap() async {
    try {
      final rows = await _db.query(
        GeneralSettingsSchema.tableAppSettings,
        orderBy: GeneralSettingsSchema.colId,
      );
      final list = rows.map(GeneralSettingModel.fromMap).toList();
      final map = <String, String>{};
      for (final item in list) {
        map[item.key] = item.value ?? '';
      }
      return Right(map);
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.queryFailed(e),
      );
    }
  }

  @override
  Future<Either<OfflineFailure, void>> upsertMany({
    required Map<String, String> settings,
    required int? userId,
  }) async {
    try {
      await _db.transaction((txn) async {
        final now = DateTime.now().toIso8601String();
        for (final entry in settings.entries) {
          final existing = await txn.query(
            GeneralSettingsSchema.tableAppSettings,
            columns: [GeneralSettingsSchema.colId],
            where: '${GeneralSettingsSchema.colKey} = ?',
            whereArgs: [entry.key],
            limit: 1,
          );

          if (existing.isEmpty) {
            await txn.insert(GeneralSettingsSchema.tableAppSettings, {
              GeneralSettingsSchema.colKey: entry.key,
              GeneralSettingsSchema.colValue: entry.value,
              GeneralSettingsSchema.colCreatedBy: userId,
              GeneralSettingsSchema.colUpdatedBy: userId,
              GeneralSettingsSchema.colCreatedAt: now,
              GeneralSettingsSchema.colUpdatedAt: now,
            });
          } else {
            await txn.update(
              GeneralSettingsSchema.tableAppSettings,
              {
                GeneralSettingsSchema.colValue: entry.value,
                GeneralSettingsSchema.colUpdatedBy: userId,
                GeneralSettingsSchema.colUpdatedAt: now,
              },
              where: '${GeneralSettingsSchema.colKey} = ?',
              whereArgs: [entry.key],
            );
          }
        }
      });
      return const Right(null);
    } catch (e) {
      return Left(
        e is DatabaseException
            ? OfflineFailure.fromSqliteException(e)
            : OfflineFailure.updateFailed(e),
      );
    }
  }
}
