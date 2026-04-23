import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../routes/app_paths.dart';
import '../../activation/models/activation_mode.dart';
import '../../activation/repos/activation_repository.dart';

part 'installation_state.dart';

class InstallationCubit extends Cubit<InstallationState> {
  InstallationCubit(this._activationRepository, this._connectivity)
    : super(const InstallationState()) {
    recheckInternetConnection();
  }

  final ActivationRepository _activationRepository;
  final Connectivity _connectivity;
  final formKey = GlobalKey<FormState>();
  final purchaseKeyController = TextEditingController();

  @override
  Future<void> close() {
    purchaseKeyController.dispose();
    return super.close();
  }

  void setMode(ActivationMode mode) {
    emit(state.copyWith(selectedMode: mode, clearError: true));
  }

  Future<void> recheckInternetConnection() async {
    emit(state.copyWith(isCheckingConnection: true, clearError: true));
    final hasConnection = await _hasInternetConnection();
    emit(
      state.copyWith(
        isCheckingConnection: false,
        hasInternetConnection: hasConnection,
      ),
    );
  }

  void onPurchaseKeyChanged(String value) {
    emit(state.copyWith(clearError: true));
  }

  Future<void> activate() async {
    if (!state.hasInternetConnection) {
      emit(state.copyWith(errorMessage: 'يجب الاتصال بالإنترنت قبل التفعيل'));
      return;
    }

    final selectedMode = state.selectedMode;
    if (selectedMode == null) {
      emit(state.copyWith(errorMessage: 'اختر نمط تشغيل الجهاز أولاً'));
      return;
    }

    if (!_isPurchaseKeyValid()) {
      emit(
        state.copyWith(
          errorMessage:
              'مفتاح الشراء يجب أن يكون 16 رقم بالصيغة xxxx-xxxx-xxxx-xxxx',
        ),
      );
      return;
    }

    emit(
      state.copyWith(isSubmitting: true, clearError: true, clearNextPath: true),
    );
    final serial = purchaseKeyController.text.trim();
    final result = await _activationRepository.activateDevice(
      purchaseSerial: serial,
      mode: selectedMode,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isSubmitting: false, errorMessage: failure.message),
      ),
      (_) {
        final nextPath =
            selectedMode == ActivationMode.online
                ? AppPaths.syncing
                : AppPaths.setup;
        emit(state.copyWith(isSubmitting: false, nextPath: nextPath));
      },
    );
  }

  bool _isPurchaseKeyValid() {
    final raw = purchaseKeyController.text.trim();
    return RegExp(r'^\d{4}-\d{4}-\d{4}-\d{4}$').hasMatch(raw);
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      final hasNetworkInterface = connectivityResult.any(
        (result) => result != ConnectivityResult.none,
      );
      if (!hasNetworkInterface) return false;

      final addresses = await InternetAddress.lookup('eatic.inote-tech.com');
      return addresses.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
