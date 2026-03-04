import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SecureLocalStorageService {
  static FlutterSecureStorage? storage;

  static void init() {
    AndroidOptions androidOptions = const AndroidOptions(
      encryptedSharedPreferences: true,
    );

    IOSOptions iosOptions = IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    );

    // macOS: groupId must match keychain-access-groups in entitlements.
    MacOsOptions macOsOptions = const MacOsOptions(
      groupId: 'com.eatic.inote.app',
    );

    storage = FlutterSecureStorage(
      aOptions: androidOptions,
      iOptions: iosOptions,
      mOptions: macOsOptions,
    );
  }

  static Future<void> writeSecureData(String key, value) async {
    await storage!.write(key: key, value: value);
  }

  static Future<String> readSecureData(String key) async {
    String value = await storage!.read(key: key) ?? '';

    return value;
  }

  static Future<void> deleteSecureData(String key) async {
    await storage!.delete(key: key);
  }

  static Future<void> deleteAllSecureData() async {
    await storage!.deleteAll();
  }

  static Future<void> saveUserToken(String token) async {
    await writeSecureData("token", token);
  }

  static Future<String> getUserToken() async {
    return await readSecureData("token");
  }
}
