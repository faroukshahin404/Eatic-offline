import 'package:dio/dio.dart';

class ActivationDioRequest {
  ActivationDioRequest(Dio dio) : _dio = dio;

  final Dio _dio;

  Future<Response<Map<String, dynamic>>> activate({
    required String serial,
    required String signatureHash,
  }) {
    return _dio.post<Map<String, dynamic>>(
      '/api/v1/licensing/activate',
      options: Options(
        headers: {
          'X-Device-Serial': serial,
          'X-Device-Signature': signatureHash,
        },
      ),
    );
  }
}
