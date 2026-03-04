import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/flutter_secure_storage.dart';
import '../../payment_methods/model/payment_method_model.dart';
import '../../users/model/user_model.dart';
import '../repos/offline/add_new_payment_method_offline_repos.dart';

part 'add_new_payment_method_state.dart';

class AddNewPaymentMethodCubit extends Cubit<AddNewPaymentMethodState> {
  AddNewPaymentMethodCubit(this._repo) : super(AddNewPaymentMethodInitial());

  final AddNewPaymentMethodOfflineRepository _repo;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  PaymentMethodModel? paymentMethod;

  @override
  Future<void> close() {
    nameController.dispose();
    return super.close();
  }

  void setPaymentMethod(PaymentMethodModel? paymentMethod) {
    this.paymentMethod = paymentMethod;
    if (paymentMethod != null) {
      nameController.text = paymentMethod.name ?? '';
    }
  }

  /// Reads stored user from secure storage. Returns null if not found or invalid.
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

  Future<void> createPaymentMethod() async {
    if (formKey.currentState?.validate() != true) return;
    final name = nameController.text.trim();
    final userModel = await _getStoredUser();
    final model = PaymentMethodModel(
      vendorId: null,
      name: name,
      createdBy: userModel?.id,
    );
    emit(AddNewPaymentMethodLoading());
    final result = await _repo.insert(model);
    result.fold(
      (f) => emit(AddNewPaymentMethodError(f.failureMessage ?? 'Error')),
      (id) => emit(AddNewPaymentMethodSaved(id: id)),
    );
  }

  Future<void> updatePaymentMethod() async {
    if (paymentMethod == null || paymentMethod!.id == null) {
      emit(AddNewPaymentMethodError('Payment method id is required for update'));
      return;
    }
    if (formKey.currentState?.validate() != true) return;
    final name = nameController.text.trim();
    final now = DateTime.now().toIso8601String();
    final updated = paymentMethod!.copyWith(name: name, updatedAt: now);
    emit(AddNewPaymentMethodLoading());
    final result = await _repo.update(updated);
    result.fold(
      (f) => emit(AddNewPaymentMethodError(f.failureMessage ?? 'Error')),
      (_) => emit(AddNewPaymentMethodSaved(id: paymentMethod!.id)),
    );
  }

  /// Saves: creates when [paymentMethod] is null, updates when editing.
  Future<void> savePaymentMethod() async {
    if (paymentMethod != null) {
      await updatePaymentMethod();
    } else {
      await createPaymentMethod();
    }
  }
}
