part of 'add_new_delivery_cubit.dart';

sealed class AddNewDeliveryState {}

final class AddNewDeliveryInitial extends AddNewDeliveryState {}

final class AddNewDeliveryLoading extends AddNewDeliveryState {}

final class AddNewDeliveryBranchesLoaded extends AddNewDeliveryState {}

final class AddNewDeliveryError extends AddNewDeliveryState {
  final String message;
  AddNewDeliveryError(this.message);
}

final class AddNewDeliverySaved extends AddNewDeliveryState {
  final int id;
  final bool isUpdate;
  AddNewDeliverySaved(this.id, {this.isUpdate = false});
}
