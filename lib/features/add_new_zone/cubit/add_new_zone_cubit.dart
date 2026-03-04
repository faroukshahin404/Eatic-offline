import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../branches/model/branch_model.dart';
import '../../branches/repos/offline/branches_offline_repos.dart';
import '../../zones/model/zone_model.dart';
import '../repos/offline/add_new_zone_offline_repos.dart';

part 'add_new_zone_state.dart';

class AddNewZoneCubit extends Cubit<AddNewZoneState> {
  AddNewZoneCubit(this._branchesRepo, this._zoneRepo)
      : super(AddNewZoneInitial());

  final BranchesOfflineRepository _branchesRepo;
  final AddNewZoneOfflineRepository _zoneRepo;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final deliveryCostController = TextEditingController();

  List<BranchModel> branches = [];
  BranchModel? selectedBranch;

  /// When set, we are editing; save will call update instead of insert.
  ZoneModel? existingZone;

  /// When set, loadBranches will fetch this zone and prefill the form (edit mode).
  int? _zoneIdForEdit;

  @override
  Future<void> close() {
    nameController.dispose();
    deliveryCostController.dispose();
    return super.close();
  }

  void setZoneIdForEdit(int id) {
    _zoneIdForEdit = id;
  }

  Future<void> loadBranches() async {
    emit(AddNewZoneLoading());
    final result = await _branchesRepo.getAll();
    result.fold(
      (f) => emit(AddNewZoneError(f.failureMessage ?? 'Error')),
      (list) async {
        branches = list;
        if (list.isNotEmpty && selectedBranch == null) {
          selectedBranch = list.first;
        }
        if (_zoneIdForEdit != null) {
          final zoneResult =
              await _zoneRepo.getZoneById(_zoneIdForEdit!);
          zoneResult.fold(
            (f) => emit(AddNewZoneError(f.failureMessage ?? 'Error')),
            (zone) {
              if (zone != null) setExistingZone(zone);
              _zoneIdForEdit = null;
              emit(AddNewZoneBranchesLoaded());
            },
          );
        } else {
          emit(AddNewZoneBranchesLoaded());
        }
      },
    );
  }

  void setExistingZone(ZoneModel? zone) {
    existingZone = zone;
    if (zone != null) {
      nameController.text = zone.name ?? '';
      deliveryCostController.text = zone.deliveryCharge != null
          ? zone.deliveryCharge!.toString()
          : '';
      final idx = branches.indexWhere((b) => b.id == zone.branchId);
      if (idx >= 0) selectedBranch = branches[idx];
    }
  }

  void setSelectedBranch(BranchModel? branch) {
    selectedBranch = branch;
    emit(AddNewZoneBranchesLoaded());
  }

  Future<void> saveZone() async {
    if (formKey.currentState?.validate() != true) return;
    if (selectedBranch == null) {
      emit(AddNewZoneError('Please select a branch'));
      return;
    }
    final costText = deliveryCostController.text.trim();
    final deliveryCharge = costText.isEmpty
        ? 0.0
        : (double.tryParse(costText.replaceFirst(',', '.')) ?? 0.0);
    final model = ZoneModel(
      id: existingZone?.id,
      vendorId: existingZone?.vendorId,
      branchId: selectedBranch!.id,
      name: nameController.text.trim(),
      deliveryCharge: deliveryCharge,
      createdAt: existingZone?.createdAt,
      updatedAt: existingZone?.updatedAt,
    );
    emit(AddNewZoneLoading());
    final isUpdate = existingZone?.id != null;
    final result = isUpdate
        ? await _zoneRepo.update(model)
        : await _zoneRepo.insert(model);
    result.fold(
      (f) => emit(AddNewZoneError(f.failureMessage ?? 'Error')),
      (id) => emit(AddNewZoneSaved(
        existingZone?.id ?? id,
        isUpdate: isUpdate,
      )),
    );
  }
}
