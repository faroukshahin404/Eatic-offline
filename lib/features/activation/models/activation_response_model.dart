class ActivationResponseModel {
  const ActivationResponseModel({required this.token, required this.expiresAt});

  final String token;
  final String? expiresAt;

  factory ActivationResponseModel.fromMap(Map<String, dynamic> map) {
    final data = map['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Missing activation data payload');
    }

    final token = data['token'];
    if (token is! String || token.trim().isEmpty) {
      throw const FormatException('Activation token is missing');
    }

    final activation = data['activation'];
    String? expiresAt;
    if (activation is Map<String, dynamic>) {
      final rawExpiresAt = activation['expires_at'];
      if (rawExpiresAt is String && rawExpiresAt.trim().isNotEmpty) {
        expiresAt = rawExpiresAt;
      }
    }

    return ActivationResponseModel(token: token, expiresAt: expiresAt);
  }
}
