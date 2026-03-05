part of 'add_new_category_cubit.dart';

sealed class AddNewCategoryState {}

final class AddNewCategoryInitial extends AddNewCategoryState {}

final class AddNewCategoryLoading extends AddNewCategoryState {}

final class AddNewCategoryCategoriesLoaded extends AddNewCategoryState {}

final class AddNewCategoryError extends AddNewCategoryState {
  final String message;
  AddNewCategoryError(this.message);
}

final class AddNewCategorySaved extends AddNewCategoryState {
  final int id;
  final bool isUpdate;
  AddNewCategorySaved(this.id, {this.isUpdate = false});
}
