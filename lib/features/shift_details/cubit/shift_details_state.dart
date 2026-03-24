part of 'shift_details_cubit.dart';

sealed class ShiftDetailsState {}

final class ShiftDetailsInitial extends ShiftDetailsState {}

final class ShiftDetailsLoading extends ShiftDetailsState {}

final class ShiftDetailsLoaded extends ShiftDetailsState {}

final class ShiftDetailsError extends ShiftDetailsState {
  final String message;
  ShiftDetailsError({required this.message});
}

final class ShiftDetailsOrdersLoading extends ShiftDetailsState {}

final class ShiftDetailsOrdersLoaded extends ShiftDetailsState {
  ShiftDetailsOrdersLoaded();
}

final class ShiftDetailsOrdersError extends ShiftDetailsState {
  final String message;
  ShiftDetailsOrdersError({required this.message});
}
