// import 'dart:developer';

// import 'package:dio/dio.dart';
// import 'package:easy_localization/easy_localization.dart';

// abstract class CommonFailedModel {
//   String? failureMessage;
//   String? failureMessageTitle;
//   final DioException modelException;

//   CommonFailedModel({
//     required this.modelException,
//     this.failureMessageTitle,
//     required this.failureMessage,
//   });
// }

// class DioFailure extends CommonFailedModel {
//   DioFailure({
//     super.failureMessage,
//     super.failureMessageTitle,
//     required super.modelException,
//   });

//   factory DioFailure.fromDioException({
//     DioExceptionType? dioType,
//     DioException? exception,
//   }) {
//     switch (dioType!) {
//       case DioExceptionType.connectionTimeout:
//         log("DioExceptionType.connectionTimeout");
//         return DioFailure(
//           failureMessage: 'errors.connection_error'.tr(),
//           modelException: exception!,
//         );
//       case DioExceptionType.sendTimeout:
//         log("DioExceptionType.sendTimeout");
//         return DioFailure(
//           failureMessage: 'errors.timeout_30s'.tr(),
//           modelException: exception!,
//         );
//       case DioExceptionType.receiveTimeout:
//         log("DioExceptionType.receiveTimeout");
//         return DioFailure(
//           failureMessage: 'errors.timeout_30s'.tr(),
//           modelException: exception!,
//         );
//       case DioExceptionType.badCertificate:
//         log("DioExceptionType.badCertificate");
//         return DioFailure(
//           failureMessage: 'errors.bad_certificate'.tr(),
//           modelException: exception!,
//         );
//       case DioExceptionType.badResponse:
//         log("DioExceptionType.badResponse");

//         return DioFailure(
//           failureMessage: 'errors.user_not_verified'.tr(),
//           modelException: exception!,
//         );

//       case DioExceptionType.cancel:
//         log("DioExceptionType.cancel");
//         return DioFailure(
//           failureMessage: 'errors.request_canceled'.tr(),
//           modelException: exception!,
//         );

//       case DioExceptionType.connectionError:
//         return DioFailure(
//           failureMessage: 'errors.connection_error'.tr(),
//           modelException: exception!,
//         );

//       case DioExceptionType.unknown:
//         log("DioExceptionType.unknown");
//         return DioFailure(
//           failureMessage: 'errors.unknown'.tr(),
//           modelException: exception!,
//         );
//     }
//   }
// }
