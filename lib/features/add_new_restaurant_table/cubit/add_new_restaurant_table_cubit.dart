import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/flutter_secure_storage.dart';
import '../../branches/model/branch_model.dart';
import '../../branches/repos/offline/branches_offline_repos.dart';
import '../../dining_areas/model/dining_area_model.dart';
import '../../dining_areas/repos/offline/dining_areas_offline_repos.dart';
import '../../restaurant_tables/model/restaurant_table_model.dart';
import '../../users/model/user_model.dart';
import '../repos/offline/add_new_restaurant_table_offline_repos.dart';

part 'add_new_restaurant_table_state.dart';

class AddNewRestaurantTableCubit extends Cubit<AddNewRestaurantTableState> {
  AddNewRestaurantTableCubit(
    this._branchesRepo,
    this._diningAreasRepo,
    this._restaurantTableRepo,
  ) : super(AddNewRestaurantTableInitial());

  final BranchesOfflineRepository _branchesRepo;
  final DiningAreasOfflineRepository _diningAreasRepo;
  final AddNewRestaurantTableOfflineRepository _restaurantTableRepo;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  List<BranchModel> branches = [];
  BranchModel? selectedBranch;

  List<DiningAreaModel> diningAreas = [];
  DiningAreaModel? selectedDiningArea;

  /// When set, we are in edit mode.
  RestaurantTableModel? restaurantTable;
  bool _diningAreaPrefilled = false;

  @override
  Future<void> close() {
    nameController.dispose();
    return super.close();
  }

  void setRestaurantTable(RestaurantTableModel? table) {
    restaurantTable = table;
    if (table != null) {
      nameController.text = table.name ?? '';
    }
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

  /// Load branches first; if editing, set selectedBranch and then load dining areas for that branch.
  Future<void> loadBranches() async {
    emit(AddNewRestaurantTableLoadingBranches());
    final result = await _branchesRepo.getAll();
    result.fold(
      (f) => emit(AddNewRestaurantTableError(f.failureMessage ?? 'Error')),
      (list) {
        branches = list;
        if (list.isEmpty) {
          emit(AddNewRestaurantTableBranchesLoaded());
          return;
        }
        if (restaurantTable != null) {
          final idx = list.indexWhere((b) => b.id == restaurantTable!.branchId);
          selectedBranch = idx >= 0 ? list[idx] : list.first;
        } else {
          selectedBranch = list.first;
        }
        emit(AddNewRestaurantTableBranchesLoaded());
        // Load dining areas for selected branch (initial load for add or edit).
        if (selectedBranch != null) {
          loadDiningAreasForBranch(selectedBranch!.id!);
        }
      },
    );
  }

  void setSelectedBranch(BranchModel? branch) {
    selectedBranch = branch;
    diningAreas = [];
    selectedDiningArea = null;
    emit(AddNewRestaurantTableBranchesLoaded());
    if (branch != null) {
      loadDiningAreasForBranch(branch.id!);
    } else {
      emit(AddNewRestaurantTableDiningAreasLoaded());
    }
  }

  Future<void> loadDiningAreasForBranch(int branchId) async {
    emit(AddNewRestaurantTableLoadingDiningAreas());
    final result = await _diningAreasRepo.getByBranchId(branchId);
    result.fold(
      (f) => emit(
        AddNewRestaurantTableDiningAreasError(
          f.failureMessage ?? 'Failed to load dining areas',
        ),
      ),
      (list) {
        diningAreas = list;
        if (list.isNotEmpty &&
            restaurantTable != null &&
            !_diningAreaPrefilled) {
          final idx = list.indexWhere(
            (d) => d.id == restaurantTable!.diningAreaId,
          );
          selectedDiningArea = idx >= 0 ? list[idx] : list.first;
          _diningAreaPrefilled = true;
        } else if (list.isNotEmpty && selectedDiningArea == null) {
          selectedDiningArea = list.first;
        } else if (list.isEmpty) {
          selectedDiningArea = null;
        }
        emit(AddNewRestaurantTableDiningAreasLoaded());
      },
    );
  }

  void setSelectedDiningArea(DiningAreaModel? area) {
    selectedDiningArea = area;
    emit(AddNewRestaurantTableDiningAreasLoaded());
  }

  Future<void> saveRestaurantTable() async {
    if (formKey.currentState?.validate() != true) return;
    if (selectedBranch == null) {
      emit(AddNewRestaurantTableError('Please select a branch'));
      return;
    }
    if (selectedDiningArea == null) {
      emit(AddNewRestaurantTableError('Please select a dining area'));
      return;
    }
    final user = await _getStoredUser();
    final name = nameController.text.trim();
    final now = DateTime.now().toIso8601String();
    final model = RestaurantTableModel(
      id: restaurantTable?.id,
      branchId: selectedBranch!.id,
      diningAreaId: selectedDiningArea!.id,
      name: name,
      isEmpty: restaurantTable?.isEmpty ?? 1,
      createdBy: user?.id ?? restaurantTable?.createdBy,
      createdAt: restaurantTable?.createdAt,
      updatedAt: now,
    );
    emit(AddNewRestaurantTableSaving());
    final isUpdate = restaurantTable?.id != null;
    final result = isUpdate
        ? await _restaurantTableRepo.update(model)
        : await _restaurantTableRepo.insert(model);
    result.fold(
      (f) => emit(AddNewRestaurantTableError(f.failureMessage ?? 'Error')),
      (id) => emit(
        AddNewRestaurantTableSaved(
          restaurantTable?.id ?? id,
          isUpdate: isUpdate,
        ),
      ),
    );
  }
}
