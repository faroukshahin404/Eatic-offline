import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

abstract class CommonOfflineFailedModel {
  String? failureMessage;
  String? failureMessageTitle;
  final Object? modelException;

  CommonOfflineFailedModel({
    required this.failureMessage,
    this.failureMessageTitle,
    required this.modelException,
  });
}

class OfflineFailure extends CommonOfflineFailedModel {
  OfflineFailure({
    super.failureMessage,
    super.failureMessageTitle,
    required super.modelException,
  });

  factory OfflineFailure.fromSqliteException(dynamic e) {
    if (e is DatabaseException) {
      if (e.isUniqueConstraintError()) {
        log('DatabaseException: unique constraint');
        return OfflineFailure(
          failureMessage: 'errors.unique_constraint'.tr(),
          modelException: e,
        );
      }
      if (e.isNoSuchTableError()) {
        log('DatabaseException: no such table');
        return OfflineFailure(
          failureMessage: 'errors.no_such_table'.tr(),
          modelException: e,
        );
      }
      if (e.isDatabaseClosedError()) {
        log('DatabaseException: database closed');
        return OfflineFailure(
          failureMessage: 'errors.db_not_init'.tr(),
          modelException: e,
        );
      }
      log('DatabaseException: ${e.result}');
      return OfflineFailure(
        failureMessage: 'errors.sqlite_unknown'.tr(),
        modelException: e,
      );
    }
    log('OfflineFailure: unknown - $e');
    return OfflineFailure(
      failureMessage: 'errors.unknown'.tr(),
      modelException: e,
    );
  }

  factory OfflineFailure.insertFailed(Object e) {
    log('OfflineFailure.insertFailed: $e');
    return OfflineFailure(
      failureMessage: 'errors.insert_failed'.tr(),
      modelException: e,
    );
  }

  factory OfflineFailure.updateFailed(Object e) {
    log('OfflineFailure.updateFailed: $e');
    return OfflineFailure(
      failureMessage: 'errors.update_failed'.tr(),
      modelException: e,
    );
  }

  factory OfflineFailure.deleteFailed(Object e) {
    log('OfflineFailure.deleteFailed: $e');
    return OfflineFailure(
      failureMessage: 'errors.delete_failed'.tr(),
      modelException: e,
    );
  }

  factory OfflineFailure.queryFailed(Object e) {
    log('OfflineFailure.queryFailed: $e');
    return OfflineFailure(
      failureMessage: 'errors.query_failed'.tr(),
      modelException: e,
    );
  }

  factory OfflineFailure.invalidArgument(String message) {
    log('OfflineFailure.invalidArgument: $message');
    return OfflineFailure(
      failureMessage: 'errors.invalid_argument'.tr(),
      modelException: message,
    );
  }
}
