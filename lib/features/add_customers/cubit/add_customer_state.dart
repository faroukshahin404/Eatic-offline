part of 'add_customer_cubit.dart';

sealed class AddCustomerState {}

final class AddCustomerInitial extends AddCustomerState {}

final class AddCustomerLoading extends AddCustomerState {}

final class AddCustomerReady extends AddCustomerState {}

final class AddCustomerError extends AddCustomerState {
  final String message;
  AddCustomerError({required this.message});
}

final class AddCustomerSaved extends AddCustomerState {}
