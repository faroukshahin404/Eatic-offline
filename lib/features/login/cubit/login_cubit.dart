import 'dart:convert';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/flutter_secure_storage.dart';
import '../../users/model/user_model.dart';
import '../repos/offline/login_offline_repos.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._repo) : super(LoginInitial());

  final LoginOfflineRepository _repo;

  final formKey = GlobalKey<FormState>();
  final codeController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Future<void> close() {
    codeController.dispose();
    passwordController.dispose();
    return super.close();
  }

  Future<void> login() async {
    if (formKey.currentState?.validate() != true) return;
    emit(LoginLoading());
    final result = await _repo.findByCodeAndPassword(
      codeController.text.trim(),
      passwordController.text,
    );
    result.fold((f) => emit(LoginError(f.failureMessage ?? 'Error')), (
      user,
    ) async {
      if (user == null) {
        emit(LoginError('login.invalid_credentials'.tr()));
      } else {
        try {
          final json = jsonEncode(user.toJson());
          await SecureLocalStorageService.writeSecureData('user', json);
        } catch (_) {
          // Keychain may fail on macOS without proper signing (e.g. -34018).
          // Login still succeeds; user session just won't persist to secure storage.
          log(
            'Keychain may fail on macOS without proper signing (e.g. -34018).',
          );
        }
        emit(LoginSuccess(user));
      }
    });
  }
}
