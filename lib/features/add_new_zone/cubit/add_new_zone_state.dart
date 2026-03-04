part of 'add_new_zone_cubit.dart';

sealed class AddNewZoneState {}

final class AddNewZoneInitial extends AddNewZoneState {}

final class AddNewZoneLoading extends AddNewZoneState {}

final class AddNewZoneBranchesLoaded extends AddNewZoneState {}

final class AddNewZoneError extends AddNewZoneState {
  final String message;
  AddNewZoneError(this.message);
}

final class AddNewZoneSaved extends AddNewZoneState {
  final int id;
  final bool isUpdate;
  AddNewZoneSaved(this.id, {this.isUpdate = false});
}
