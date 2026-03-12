import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/core_models/role_model.dart';
import '../../branches/model/branch_model.dart';
import '../../branches/repos/offline/branches_offline_repos.dart';
import '../../users/model/user_model.dart';
import '../repos/offline/add_user_offline_repos.dart';

part 'add_user_state.dart';

class AddUserCubit extends Cubit<AddUserState> {
  AddUserCubit(this._repo, this._branchesRepo) : super(AddUserInitial());

  final AddUserOfflineRepository _repo;
  final BranchesOfflineRepository _branchesRepo;

  final formKey = GlobalKey<FormState>();
  final codeController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  int selectedRoleId = 1;
  UserModel? currentUser;

  List<RoleModel> roles = [];
  RoleModel? selectedRole;

  List<BranchModel> branches = [];
  int? selectedBranchId;

  void setFromUser(UserModel? user) {
    currentUser = user;
    if (user == null) {
      clearControllers();
      return;
    }
    codeController.text = user.code;
    nameController.text = user.name ?? '';
    selectedRoleId = user.roleId;
    selectedBranchId = user.branchId;
    _syncSelectedRoleFromId();
  }

  void clearControllers() {
    currentUser = null;
    selectedRole = null;
    selectedBranchId = null;
    codeController.clear();
    nameController.clear();
    passwordController.clear();
    selectedRoleId = 1;
  }

  void setSelectedRole(RoleModel? role) {
    selectedRole = role;
    selectedRoleId = role?.id ?? 1;
    if (_isCashier(role) == false) {
      selectedBranchId = null;
    }
    emit(AddUserLoaded());
  }

  bool _isCashier(RoleModel? role) =>
      role?.name.toLowerCase() == 'cashier';

  void setSelectedBranch(BranchModel? branch) {
    selectedBranchId = branch?.id;
    emit(AddUserLoaded());
  }

  BranchModel? get selectedBranch =>
      selectedBranchId == null
          ? null
          : branches.where((b) => b.id == selectedBranchId).firstOrNull;

  void setSelectedBranchId(int? id) {
    selectedBranchId = id;
    emit(AddUserLoaded());
  }

  void _syncSelectedRoleFromId() {
    selectedRole = roles.where((r) => r.id == selectedRoleId).firstOrNull;
  }

  @override
  Future<void> close() {
    codeController.dispose();
    nameController.dispose();
    passwordController.dispose();
    return super.close();
  }

  Future<void> addUser(UserModel user) async {
    emit(AddUserLoading());
    final result = await _repo.create(user);
    result.fold(
      (f) => emit(AddUserError(f.failureMessage ?? 'Error')),
      (id) {
        emit(AddUserSaved(id: id));
      },
    );
  }

  Future<void> editUser(UserModel user) async {
    emit(AddUserLoading());
    final result = await _repo.update(user);
    result.fold(
      (f) => emit(AddUserError(f.failureMessage ?? 'Error')),
      (_) => emit(AddUserSaved()),
    );
  }

  Future<void> getById({int? id}) async {
    if (id == null) {
      return;
    }
    final result = await _repo.getById(id);
    result.fold(
      (f) {
        emit(AddUserError(f.failureMessage ?? 'Error'));
      },
      (UserModel? user) {
        setFromUser(user);
        _syncSelectedRoleFromId();
        emit(AddUserLoaded());
      },
    );
  }

  Future<void> getRoles({int? id}) async {
    final rolesResult = await _repo.getRoles();
    final branchesResult = await _branchesRepo.getAll();
    rolesResult.fold(
      (f) => emit(AddUserError(f.failureMessage ?? 'Error')),
      (roles) {
        this.roles = roles;
        branches = branchesResult.getOrElse(() => []);
        _syncSelectedRoleFromId();
        if (id != null) {
          getById(id: id);
        } else {
          emit(AddUserLoaded());
        }
      },
    );
  }
}
