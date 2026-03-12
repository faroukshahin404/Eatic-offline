part of 'add_new_dining_area_cubit.dart';

sealed class AddNewDiningAreaState {}

final class AddNewDiningAreaInitial extends AddNewDiningAreaState {}

final class AddNewDiningAreaLoading extends AddNewDiningAreaState {}

final class AddNewDiningAreaBranchesLoaded extends AddNewDiningAreaState {}

final class AddNewDiningAreaError extends AddNewDiningAreaState {
  final String message;
  AddNewDiningAreaError(this.message);
}

final class AddNewDiningAreaSaved extends AddNewDiningAreaState {
  final int id;
  final bool isUpdate;
  AddNewDiningAreaSaved(this.id, {this.isUpdate = false});
}
