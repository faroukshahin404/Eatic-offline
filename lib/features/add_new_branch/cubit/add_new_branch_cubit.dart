import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/flutter_secure_storage.dart';
import '../../branches/model/branch_model.dart';
import '../../users/model/user_model.dart';
import '../repos/offline/add_new_branch_offline_repos.dart';

part 'add_new_branch_state.dart';

class AddNewBranchCubit extends Cubit<AddNewBranchState> {
  AddNewBranchCubit(this._repo) : super(AddNewBranchInitial());

  final AddNewBranchOfflineRepository _repo;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  BranchModel? branch;

  @override
  Future<void> close() {
    nameController.dispose();
    return super.close();
  }

  void setBranch(BranchModel? branch) {
    this.branch = branch;
    if (branch != null) {
      nameController.text = branch.name;
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

  Future<void> createBranch() async {
    if (formKey.currentState?.validate() != true) return;
    final name = nameController.text.trim();
    final now = DateTime.now().toIso8601String();
    final userModel = await _getStoredUser();
    final newBranch = BranchModel(
      name: name,
      createdAt: now,
      updatedAt: now,
      createdBy: userModel,
    );
    emit(AddNewBranchLoading());
    final result = await _repo.create(newBranch);
    result.fold(
      (f) => emit(AddNewBranchError(f.failureMessage ?? 'Error')),
      (id) => emit(AddNewBranchSaved(id: id)),
    );
  }

  Future<void> updateBranch() async {
    if (branch == null || branch!.id == null) {
      emit(AddNewBranchError('Branch id is required for update'));
      return;
    }
    if (formKey.currentState?.validate() != true) return;
    final name = nameController.text.trim();
    final now = DateTime.now().toIso8601String();
    final updated = branch!.copyWith(
      name: name,
      updatedAt: now,
    );
    emit(AddNewBranchLoading());
    final result = await _repo.update(updated);
    result.fold(
      (f) => emit(AddNewBranchError(f.failureMessage ?? 'Error')),
      (_) => emit(AddNewBranchSaved(id: branch!.id)),
    );
  }

  /// Saves the branch: creates when [branch] is null, updates when editing.
  Future<void> saveBranch() async {
    if (branch != null) {
      await updateBranch();
    } else {
      await createBranch();
    }
  }
}
