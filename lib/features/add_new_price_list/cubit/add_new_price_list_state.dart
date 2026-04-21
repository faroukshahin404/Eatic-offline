part of 'add_new_price_list_cubit.dart';

sealed class AddNewPriceListState {}

final class AddNewPriceListInitial extends AddNewPriceListState {}

final class AddNewPriceListLoadingCurrencies extends AddNewPriceListState {}

final class AddNewPriceListReady extends AddNewPriceListState {}

/// Persisting create or update.
final class AddNewPriceListSaving extends AddNewPriceListState {}

final class AddNewPriceListSaved extends AddNewPriceListState {
  final int? id;
  final bool isUpdate;
  AddNewPriceListSaved({this.id, this.isUpdate = false});
}

final class AddNewPriceListError extends AddNewPriceListState {
  final String message;
  AddNewPriceListError(this.message);
}
