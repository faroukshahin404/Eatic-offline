part of 'price_lists_cubit.dart';

sealed class PriceListsState {}

final class PriceListsInitial extends PriceListsState {}

final class PriceListsLoading extends PriceListsState {}

final class PriceListsLoaded extends PriceListsState {}

final class PriceListsError extends PriceListsState {
  final String message;
  PriceListsError({required this.message});
}

final class PriceListsDeleteError extends PriceListsState {
  final String message;
  PriceListsDeleteError({required this.message});
}
