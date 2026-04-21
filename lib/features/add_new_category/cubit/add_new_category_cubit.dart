import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../categories/model/category_model.dart';
import '../../categories/repos/offline/categories_offline_repos.dart';
import '../repos/offline/add_new_category_offline_repos.dart';

part 'add_new_category_state.dart';

class AddNewCategoryCubit extends Cubit<AddNewCategoryState> {
  AddNewCategoryCubit(this._categoriesRepo, this._addNewCategoryRepo)
      : super(AddNewCategoryInitial());

  final CategoriesOfflineRepository _categoriesRepo;
  final AddNewCategoryOfflineRepository _addNewCategoryRepo;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  List<CategoryModel> categories = [];
  /// Selected parent category; null means no parent (top-level).
  CategoryModel? selectedParent;

  /// When set, we are in edit mode.
  CategoryModel? category;

  @override
  Future<void> close() {
    nameController.dispose();
    return super.close();
  }

  void setCategory(CategoryModel? cat) {
    category = cat;
    if (cat != null) {
      nameController.text = cat.name ?? '';
    } else {
      nameController.clear();
      selectedParent = null;
    }
  }

  /// Load categories list for parent dropdown (from CategoriesOfflineRepository).
  Future<void> loadCategories() async {
    emit(AddNewCategoryLoadingCategories());
    final result = await _categoriesRepo.getAll();
    result.fold(
      (f) => emit(AddNewCategoryError(f.failureMessage ?? 'Error')),
      (list) {
        categories = list;
        if (category != null) {
          final idx = list.indexWhere((c) => c.id == category!.parentId);
          selectedParent = idx >= 0 ? list[idx] : null;
        }
        emit(AddNewCategoryCategoriesLoaded());
      },
    );
  }

  void setSelectedParent(CategoryModel? parent) {
    selectedParent = parent;
    emit(AddNewCategoryCategoriesLoaded());
  }

  /// Categories available for parent dropdown (exclude current category when editing to avoid self-reference).
  List<CategoryModel> get parentDropdownCategories {
    if (category?.id == null) return categories;
    return categories.where((c) => c.id != category!.id).toList();
  }

  Future<void> saveCategory() async {
    if (formKey.currentState?.validate() != true) return;
    final name = nameController.text.trim();
    final now = DateTime.now().toIso8601String();
    final model = CategoryModel(
      id: category?.id,
      vendorId: category?.vendorId,
      name: name,
      parentId: selectedParent?.id,
      createdAt: category?.createdAt,
      updatedAt: now,
    );
    emit(AddNewCategorySaving());
    final isUpdate = category?.id != null;
    final result = isUpdate
        ? await _addNewCategoryRepo.update(model)
        : await _addNewCategoryRepo.insert(model);
    result.fold(
      (f) => emit(AddNewCategoryError(f.failureMessage ?? 'Error')),
      (id) => emit(AddNewCategorySaved(category?.id ?? id, isUpdate: isUpdate)),
    );
  }
}
