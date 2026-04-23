import '../models/activation_mode.dart';
import '../../../core/services/flutter_secure_storage.dart';

abstract class ActivationStorageKeys {
  static const String deviceToken = 'activation_device_token';
  static const String signatureHash = 'activation_signature_hash';
  static const String expiresAt = 'activation_expires_at';
  static const String installationMode = 'activation_installation_mode';
  static const String installationCompleted =
      'activation_installation_completed';
}

class ActivationStorageService {
  Future<void> saveActivation({
    required String token,
    required String signatureHash,
    required String? expiresAt,
    required ActivationMode mode,
  }) async {
    await SecureLocalStorageService.writeSecureData(
      ActivationStorageKeys.deviceToken,
      token,
    );
    await SecureLocalStorageService.writeSecureData(
      ActivationStorageKeys.signatureHash,
      signatureHash,
    );
    await SecureLocalStorageService.writeSecureData(
      ActivationStorageKeys.expiresAt,
      expiresAt ?? '',
    );
    await SecureLocalStorageService.writeSecureData(
      ActivationStorageKeys.installationMode,
      mode.value,
    );
    await SecureLocalStorageService.writeSecureData(
      ActivationStorageKeys.installationCompleted,
      '0',
    );
  }

  Future<void> markInstallationCompleted() async {
    await SecureLocalStorageService.writeSecureData(
      ActivationStorageKeys.installationCompleted,
      '1',
    );
  }

  Future<bool> hasDeviceToken() async {
    final token = await readDeviceToken();
    return token.isNotEmpty;
  }

  Future<String> readDeviceToken() {
    return SecureLocalStorageService.readSecureData(
      ActivationStorageKeys.deviceToken,
    );
  }

  Future<String> readSignatureHash() {
    return SecureLocalStorageService.readSecureData(
      ActivationStorageKeys.signatureHash,
    );
  }

  Future<String> readExpiresAt() {
    return SecureLocalStorageService.readSecureData(
      ActivationStorageKeys.expiresAt,
    );
  }

  Future<ActivationMode?> readInstallationMode() async {
    final rawMode = await SecureLocalStorageService.readSecureData(
      ActivationStorageKeys.installationMode,
    );
    return ActivationMode.fromValue(rawMode);
  }

  Future<bool> isInstallationCompleted() async {
    final raw = await SecureLocalStorageService.readSecureData(
      ActivationStorageKeys.installationCompleted,
    );
    return raw == '1';
  }

  Future<void> clearActivation() async {
    await SecureLocalStorageService.deleteSecureData(
      ActivationStorageKeys.deviceToken,
    );
    await SecureLocalStorageService.deleteSecureData(
      ActivationStorageKeys.signatureHash,
    );
    await SecureLocalStorageService.deleteSecureData(
      ActivationStorageKeys.expiresAt,
    );
    await SecureLocalStorageService.deleteSecureData(
      ActivationStorageKeys.installationMode,
    );
    await SecureLocalStorageService.deleteSecureData(
      ActivationStorageKeys.installationCompleted,
    );
  }
}
