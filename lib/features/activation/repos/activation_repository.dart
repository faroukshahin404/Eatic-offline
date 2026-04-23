import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../models/activation_failure.dart';
import '../models/activation_mode.dart';
import '../models/activation_response_model.dart';
import '../services/activation_dio_request.dart';
import '../services/activation_storage_service.dart';
import '../services/device_signature_service.dart';

typedef ActivationCall<T> = Future<Either<ActivationFailure, T>>;

abstract class ActivationRepository {
  ActivationCall<ActivationResponseModel> activateDevice({
    required String purchaseSerial,
    required ActivationMode mode,
  });
}

class ActivationRepositoryImpl implements ActivationRepository {
  ActivationRepositoryImpl(
    this._request,
    this._deviceSignatureService,
    this._activationStorageService,
  );

  final ActivationDioRequest _request;
  final DeviceSignatureService _deviceSignatureService;
  final ActivationStorageService _activationStorageService;

  @override
  ActivationCall<ActivationResponseModel> activateDevice({
    required String purchaseSerial,
    required ActivationMode mode,
  }) async {
    try {
      final signatureHash = await _deviceSignatureService.buildSignatureHash();
      final response = await _request.activate(
        serial: purchaseSerial,
        signatureHash: signatureHash,
      );
      final body = response.data;

      if (body == null) {
        return const Left(
          ActivationFailure(message: 'Empty activation response from server'),
        );
      }

      final parsed = ActivationResponseModel.fromMap(body);
      await _activationStorageService.saveActivation(
        token: parsed.token,
        signatureHash: signatureHash,
        expiresAt: parsed.expiresAt,
        mode: mode,
      );
      return Right(parsed);
    } on DioException catch (e) {
      return Left(_mapDioException(e));
    } on FormatException catch (e) {
      return Left(ActivationFailure(message: e.message));
    } catch (e) {
      return Left(ActivationFailure(message: 'Activation failed: $e'));
    }
  }

  ActivationFailure _mapDioException(DioException exception) {
    final statusCode = exception.response?.statusCode;
    final responseData = exception.response?.data;
    String message = exception.message ?? 'Activation request failed';

    if (responseData is Map<String, dynamic>) {
      final apiMessage = responseData['message'];
      if (apiMessage is String && apiMessage.trim().isNotEmpty) {
        message = apiMessage;
      }
      final errors = responseData['errors'];
      if (errors is Map<String, dynamic>) {
        final flattened = <String>[];
        for (final value in errors.values) {
          if (value is List) {
            flattened.addAll(
              value
                  .whereType<String>()
                  .map((item) => item.trim())
                  .where((item) => item.isNotEmpty),
            );
          }
        }
        if (flattened.isNotEmpty) {
          message = flattened.join('\n');
        }
      }
    }

    return ActivationFailure(message: message, statusCode: statusCode);
  }
}
