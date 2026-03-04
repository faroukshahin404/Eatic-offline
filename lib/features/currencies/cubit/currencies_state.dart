part of 'currencies_cubit.dart';

sealed class CurrenciesState {}

final class CurrenciesInitial extends CurrenciesState {}

final class CurrenciesLoading extends CurrenciesState {}

final class CurrenciesLoaded extends CurrenciesState {}

final class CurrenciesError extends CurrenciesState {
  final String message;
  CurrenciesError({required this.message});
}

final class CurrenciesDeleteError extends CurrenciesState {
  final String message;
  CurrenciesDeleteError({required this.message});
}
