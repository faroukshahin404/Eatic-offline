part of 'select_waiter_cubit.dart';

sealed class SelectWaiterState {}

final class SelectWaiterInitial extends SelectWaiterState {}

final class SelectWaiterLoading extends SelectWaiterState {}

final class SelectWaiterLoaded extends SelectWaiterState {}

final class SelectWaiterError extends SelectWaiterState {
  final String message;
  SelectWaiterError({required this.message});
}
