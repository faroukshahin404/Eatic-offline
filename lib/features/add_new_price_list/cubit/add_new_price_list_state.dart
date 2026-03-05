part of 'add_new_price_list_cubit.dart';

sealed class AddNewPriceListState {}

final class AddNewPriceListInitial extends AddNewPriceListState {}

final class AddNewPriceListLoadingCurrencies extends AddNewPriceListState {}

final class AddNewPriceListReady extends AddNewPriceListState {}

final class AddNewPriceListLoading extends AddNewPriceListState {}

final class AddNewPriceListSaved extends AddNewPriceListState {
  final int? id;
  AddNewPriceListSaved({this.id});
}

final class AddNewPriceListError extends AddNewPriceListState {
  final String message;
  AddNewPriceListError(this.message);
}
