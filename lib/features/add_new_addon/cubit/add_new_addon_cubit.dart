import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../addons/model/addon_model.dart';
import '../repos/offline/add_new_addon_offline_repos.dart';

part 'add_new_addon_state.dart';

class AddNewAddonCubit extends Cubit<AddNewAddonState> {
  AddNewAddonCubit(this._repo) : super(AddNewAddonInitial());

  final AddNewAddonOfflineRepository _repo;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();

  AddonModel? addon;

  @override
  Future<void> close() {
    nameController.dispose();
    priceController.dispose();
    return super.close();
  }

  void setAddon(AddonModel? model) {
    addon = model;
    if (model != null) {
      nameController.text = model.name ?? '';
      priceController.text = model.defaultPrice != null
          ? model.defaultPrice!.toString()
          : '';
    } else {
      nameController.clear();
      priceController.clear();
    }
  }

  Future<void> saveAddon() async {
    if (formKey.currentState?.validate() != true) return;
    final name = nameController.text.trim();
    final priceText = priceController.text.trim();
    final price = priceText.isEmpty
        ? null
        : (double.tryParse(priceText.replaceFirst(',', '.')));
    final now = DateTime.now().toIso8601String();
    final model = AddonModel(
      id: addon?.id,
      vendorId: addon?.vendorId,
      name: name,
      defaultPrice: price,
      sortOrder: addon?.sortOrder ?? 0,
      createdAt: addon?.createdAt,
      updatedAt: now,
    );
    emit(AddNewAddonSaving());
    final isUpdate = addon?.id != null;
    final result = isUpdate
        ? await _repo.update(model)
        : await _repo.insert(model);
    result.fold(
      (f) => emit(AddNewAddonError(f.failureMessage ?? 'Error')),
      (id) => emit(AddNewAddonSaved(addon?.id ?? id, isUpdate: isUpdate)),
    );
  }
}
