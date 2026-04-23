import '../models/activation_mode.dart';
import 'activation_storage_service.dart';
import 'device_signature_service.dart';

enum ActivationLaunchDestination { installation, login, setup, syncing }

class ActivationLaunchService {
  ActivationLaunchService(this._storageService, this._deviceSignatureService);

  final ActivationStorageService _storageService;
  final DeviceSignatureService _deviceSignatureService;

  Future<ActivationLaunchDestination> resolveNextDestination() async {
    final hasToken = await _storageService.hasDeviceToken();
    if (!hasToken) {
      return ActivationLaunchDestination.installation;
    }

    final savedSignature = await _storageService.readSignatureHash();
    final currentSignature = await _deviceSignatureService.buildSignatureHash();
    if (savedSignature.isEmpty || savedSignature != currentSignature) {
      await _storageService.clearActivation();
      return ActivationLaunchDestination.installation;
    }

    final completed = await _storageService.isInstallationCompleted();
    if (completed) {
      return ActivationLaunchDestination.login;
    }

    final mode = await _storageService.readInstallationMode();
    if (mode == ActivationMode.online) {
      return ActivationLaunchDestination.syncing;
    }
    if (mode == ActivationMode.offline) {
      return ActivationLaunchDestination.setup;
    }

    return ActivationLaunchDestination.installation;
  }
}
