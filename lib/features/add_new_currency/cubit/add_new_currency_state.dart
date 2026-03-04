part of 'add_new_currency_cubit.dart';

sealed class AddNewCurrencyState {}

final class AddNewCurrencyInitial extends AddNewCurrencyState {}

final class AddNewCurrencyLoading extends AddNewCurrencyState {}

final class AddNewCurrencyFormLoaded extends AddNewCurrencyState {}

final class AddNewCurrencyError extends AddNewCurrencyState {
  final String message;
  AddNewCurrencyError(this.message);
}

final class AddNewCurrencySaved extends AddNewCurrencyState {
  final int id;
  final bool isUpdate;
  AddNewCurrencySaved(this.id, {this.isUpdate = false});
}
