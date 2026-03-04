part of 'add_new_payment_method_cubit.dart';

sealed class AddNewPaymentMethodState {}

final class AddNewPaymentMethodInitial extends AddNewPaymentMethodState {}

final class AddNewPaymentMethodLoading extends AddNewPaymentMethodState {}

final class AddNewPaymentMethodSaved extends AddNewPaymentMethodState {
  AddNewPaymentMethodSaved({this.id});
  final int? id;
}

final class AddNewPaymentMethodError extends AddNewPaymentMethodState {
  AddNewPaymentMethodError(this.message);
  final String message;
}
