import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../branches/model/branch_model.dart';
import '../../branches/repos/offline/branches_offline_repos.dart';
import '../../dining_areas/model/dining_area_model.dart';
import '../repos/offline/add_new_dining_area_offline_repos.dart';

part 'add_new_dining_area_state.dart';

class AddNewDiningAreaCubit extends Cubit<AddNewDiningAreaState> {
  AddNewDiningAreaCubit(this._branchesRepo, this._diningRepo)
      : super(AddNewDiningAreaInitial());

  final BranchesOfflineRepository _branchesRepo;
  final AddNewDiningAreaOfflineRepository _diningRepo;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  List<BranchModel> branches = [];
  BranchModel? selectedBranch;

  /// When set, we are in edit mode; save will call update instead of insert.
  DiningAreaModel? diningArea;

  @override
  Future<void> close() {
    nameController.dispose();
    return super.close();
  }

  void setDiningArea(DiningAreaModel? area) {
    diningArea = area;
    if (area != null) {
      nameController.text = area.name ?? '';
    }
  }

  Future<void> loadBranches() async {
    emit(AddNewDiningAreaLoading());
    final result = await _branchesRepo.getAll();
    result.fold(
      (f) => emit(AddNewDiningAreaError(f.failureMessage ?? 'Error')),
      (list) {
        branches = list;
        if (list.isNotEmpty && diningArea != null) {
          final idx =
              list.indexWhere((b) => b.id == diningArea!.branchId);
          selectedBranch = idx >= 0 ? list[idx] : list.first;
        } else if (list.isNotEmpty && selectedBranch == null) {
          selectedBranch = list.first;
        }
        emit(AddNewDiningAreaBranchesLoaded());
      },
    );
  }

  void setSelectedBranch(BranchModel? branch) {
    selectedBranch = branch;
    emit(AddNewDiningAreaBranchesLoaded());
  }

  Future<void> saveDiningArea() async {
    if (formKey.currentState?.validate() != true) return;
    if (selectedBranch == null) {
      emit(AddNewDiningAreaError('Please select a branch'));
      return;
    }
    final name = nameController.text.trim();
    final now = DateTime.now().toIso8601String();
    final model = DiningAreaModel(
      id: diningArea?.id,
      vendorId: diningArea?.vendorId,
      branchId: selectedBranch!.id,
      name: name,
      createdAt: diningArea?.createdAt,
      updatedAt: now,
    );
    emit(AddNewDiningAreaLoading());
    final isUpdate = diningArea?.id != null;
    final result = isUpdate
        ? await _diningRepo.update(model)
        : await _diningRepo.insert(model);
    result.fold(
      (f) => emit(AddNewDiningAreaError(f.failureMessage ?? 'Error')),
      (id) => emit(AddNewDiningAreaSaved(
        diningArea?.id ?? id,
        isUpdate: isUpdate,
      )),
    );
  }
}
