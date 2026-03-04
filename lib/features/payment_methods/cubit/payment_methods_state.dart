part of 'payment_methods_cubit.dart';

sealed class PaymentMethodsState {}

final class PaymentMethodsInitial extends PaymentMethodsState {}

final class PaymentMethodsLoading extends PaymentMethodsState {}

final class PaymentMethodsLoaded extends PaymentMethodsState {}

final class PaymentMethodsError extends PaymentMethodsState {
  final String message;
  PaymentMethodsError({required this.message});
}

final class PaymentMethodsDeleteError extends PaymentMethodsState {
  final String message;
  PaymentMethodsDeleteError({required this.message});
}
