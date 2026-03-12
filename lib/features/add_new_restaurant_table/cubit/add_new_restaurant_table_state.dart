part of 'add_new_restaurant_table_cubit.dart';

sealed class AddNewRestaurantTableState {}

final class AddNewRestaurantTableInitial extends AddNewRestaurantTableState {}

final class AddNewRestaurantTableLoadingBranches
    extends AddNewRestaurantTableState {}

final class AddNewRestaurantTableBranchesLoaded
    extends AddNewRestaurantTableState {}

final class AddNewRestaurantTableLoadingDiningAreas
    extends AddNewRestaurantTableState {}

final class AddNewRestaurantTableDiningAreasLoaded
    extends AddNewRestaurantTableState {}

final class AddNewRestaurantTableDiningAreasError
    extends AddNewRestaurantTableState {
  final String message;
  AddNewRestaurantTableDiningAreasError(this.message);
}

final class AddNewRestaurantTableError extends AddNewRestaurantTableState {
  final String message;
  AddNewRestaurantTableError(this.message);
}

final class AddNewRestaurantTableSaving extends AddNewRestaurantTableState {}

final class AddNewRestaurantTableSaved extends AddNewRestaurantTableState {
  final int id;
  final bool isUpdate;
  AddNewRestaurantTableSaved(this.id, {this.isUpdate = false});
}
