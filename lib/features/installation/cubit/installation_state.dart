part of 'installation_cubit.dart';

class InstallationState {
  const InstallationState({
    this.selectedMode,
    this.hasInternetConnection = false,
    this.isCheckingConnection = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.nextPath,
  });

  final ActivationMode? selectedMode;
  final bool hasInternetConnection;
  final bool isCheckingConnection;
  final bool isSubmitting;
  final String? errorMessage;
  final String? nextPath;

  bool get canProceed =>
      !isSubmitting && hasInternetConnection && selectedMode != null;

  InstallationState copyWith({
    ActivationMode? selectedMode,
    bool keepCurrentMode = false,
    bool? hasInternetConnection,
    bool? isCheckingConnection,
    bool? isSubmitting,
    String? errorMessage,
    String? nextPath,
    bool clearError = false,
    bool clearNextPath = false,
  }) {
    return InstallationState(
      selectedMode:
          keepCurrentMode
              ? this.selectedMode
              : (selectedMode ?? this.selectedMode),
      hasInternetConnection:
          hasInternetConnection ?? this.hasInternetConnection,
      isCheckingConnection: isCheckingConnection ?? this.isCheckingConnection,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      nextPath: clearNextPath ? null : (nextPath ?? this.nextPath),
    );
  }
}
