import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/flutter_secure_storage.dart';
import '../../users/model/user_model.dart';
import '../repos/offline/reset_password_offline_repos.dart';

part 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  ResetPasswordCubit(this._repo) : super(ResetPasswordInitial());

  final ResetPasswordOfflineRepository _repo;

  final formKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Future<void> close() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    return super.close();
  }

  Future<UserModel?> _getStoredUser() async {
    try {
      final userJson = await SecureLocalStorageService.readSecureData('user');
      if (userJson.isEmpty) return null;
      final decoded = jsonDecode(userJson);
      if (decoded is! Map<String, dynamic>) return null;
      return UserModel.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> resetPassword() async {
    if (formKey.currentState?.validate() != true) return;

    final user = await _getStoredUser();
    if (user == null) {
      emit(ResetPasswordError('reset_password.error_session_not_found'.tr()));
      return;
    }

    final current = currentPasswordController.text;
    if (user.password != current) {
      emit(ResetPasswordError('reset_password.error_current_password_incorrect'.tr()));
      return;
    }

    final newPassword = newPasswordController.text.trim();
    final now = DateTime.now().toIso8601String();
    final updated = user.copyWith(password: newPassword, updatedAt: now);

    emit(ResetPasswordLoading());
    final result = await _repo.updatePassword(updated);
    if (result.isLeft()) {
      emit(ResetPasswordError(
        result.fold((f) => f.failureMessage ?? 'errors.update_failed'.tr(), (_) => ''),
      ));
      return;
    }
    try {
      await SecureLocalStorageService.writeSecureData(
        'user',
        jsonEncode(updated.toJson()),
      );
    } catch (_) {}
    emit(ResetPasswordSuccess());
  }
}
