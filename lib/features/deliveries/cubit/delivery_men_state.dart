part of 'delivery_men_cubit.dart';

sealed class DeliveryMenState {}

final class DeliveryMenInitial extends DeliveryMenState {}

final class DeliveryMenLoading extends DeliveryMenState {}

final class DeliveryMenLoaded extends DeliveryMenState {}

final class DeliveryMenError extends DeliveryMenState {
  final String message;
  DeliveryMenError({required this.message});
}

final class DeliveryMenDeleteError extends DeliveryMenState {
  final String message;
  DeliveryMenDeleteError({required this.message});
}
