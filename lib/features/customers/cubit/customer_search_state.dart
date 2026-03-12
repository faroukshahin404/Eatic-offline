part of 'customer_search_cubit.dart';

sealed class CustomerSearchState {}

final class CustomerSearchInitial extends CustomerSearchState {}

final class CustomerSearchLoading extends CustomerSearchState {}

final class CustomerSearchLoaded extends CustomerSearchState {}

final class CustomerSearchError extends CustomerSearchState {
  CustomerSearchError(this.message);
  final String message;
}

final class CustomerSearchNoResults extends CustomerSearchState {}
