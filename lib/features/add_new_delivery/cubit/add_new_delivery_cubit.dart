import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../branches/model/branch_model.dart';
import '../../branches/repos/offline/branches_offline_repos.dart';
import '../../deliveries/model/delivery_model.dart';
import '../repos/offline/add_new_delivery_offline_repos.dart';

part 'add_new_delivery_state.dart';

class AddNewDeliveryCubit extends Cubit<AddNewDeliveryState> {
  AddNewDeliveryCubit(this._branchesRepo, this._deliveryRepo)
    : super(AddNewDeliveryInitial());

  final BranchesOfflineRepository _branchesRepo;
  final AddNewDeliveryOfflineRepository _deliveryRepo;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phone1Controller = TextEditingController();
  final phone2Controller = TextEditingController();
  final addressController = TextEditingController();
  final nationalIdController = TextEditingController();

  List<BranchModel> branches = [];
  BranchModel? selectedBranch;

  /// When set, we are editing; save will call update instead of insert.
  DeliveryModel? existingDelivery;

  /// When set, loadBranches will fetch this delivery and prefill the form (edit mode).
  int? _deliveryIdForEdit;

  @override
  Future<void> close() {
    nameController.dispose();
    phone1Controller.dispose();
    phone2Controller.dispose();
    addressController.dispose();
    nationalIdController.dispose();
    return super.close();
  }

  /// Call before [loadBranches] when opening the screen for edit (pass delivery id).
  void setDeliveryIdForEdit(int id) {
    _deliveryIdForEdit = id;
  }

  Future<void> loadBranches({int? deliveryId}) async {
    if (deliveryId != null) {
      _deliveryIdForEdit = deliveryId;
    }
    emit(AddNewDeliveryLoading());
    final result = await _branchesRepo.getAll();
    result.fold((f) => emit(AddNewDeliveryError(f.failureMessage ?? 'Error')), (
      list,
    ) async {
      branches = list;
      if (list.isNotEmpty && selectedBranch == null) {
        selectedBranch = list.first;
      }
      if (_deliveryIdForEdit != null) {
        await getDeliveryData();
      } else {
        emit(AddNewDeliveryBranchesLoaded());
      }
    });
  }

  Future<void> getDeliveryData() async {
    final deliveryResult = await _deliveryRepo.getDeliveryById(
      _deliveryIdForEdit!,
    );
    deliveryResult.fold(
      (f) => emit(AddNewDeliveryError(f.failureMessage ?? 'Error')),
      (delivery) {
        if (delivery != null) setExistingDelivery(delivery);
        _deliveryIdForEdit = null;
        emit(AddNewDeliveryBranchesLoaded());
      },
    );
  }

  void setSelectedBranch(BranchModel? branch) {
    selectedBranch = branch;
    emit(AddNewDeliveryBranchesLoaded());
  }

  /// Call when opening screen for edit to prefill form and set [existingDelivery].
  void setExistingDelivery(DeliveryModel? delivery) {
    existingDelivery = delivery;
    if (delivery != null) {
      nameController.text = delivery.name ?? '';
      phone1Controller.text = delivery.phone1 ?? '';
      phone2Controller.text = delivery.phone2 ?? '';
      addressController.text = delivery.address ?? '';
      nationalIdController.text = delivery.nationalId ?? '';
      final idx = branches.indexWhere((b) => b.id == delivery.branchId);
      if (idx >= 0) selectedBranch = branches[idx];
    }
  }

  Future<void> saveDelivery() async {
    if (formKey.currentState?.validate() != true) return;
    if (selectedBranch == null) {
      emit(AddNewDeliveryError('Please select a branch'));
      return;
    }
    final model = DeliveryModel(
      id: existingDelivery?.id,
      vendorId: existingDelivery?.vendorId,
      branchId: selectedBranch!.id,
      name: nameController.text.trim(),
      phone1: phone1Controller.text.trim().isEmpty
          ? null
          : phone1Controller.text.trim(),
      phone2: phone2Controller.text.trim().isEmpty
          ? null
          : phone2Controller.text.trim(),
      address: addressController.text.trim().isEmpty
          ? null
          : addressController.text.trim(),
      nationalId: nationalIdController.text.trim().isEmpty
          ? null
          : nationalIdController.text.trim(),
      createdAt: existingDelivery?.createdAt,
      updatedAt: existingDelivery?.updatedAt,
    );
    emit(AddNewDeliveryLoading());
    final result = existingDelivery?.id != null
        ? await _deliveryRepo.update(model)
        : await _deliveryRepo.insert(model);
    final isUpdate = existingDelivery?.id != null;
    result.fold(
      (f) => emit(AddNewDeliveryError(f.failureMessage ?? 'Error')),
      (id) => emit(
        AddNewDeliverySaved(existingDelivery?.id ?? id, isUpdate: isUpdate),
      ),
    );
  }
}
