part of 'restaurant_tables_cubit.dart';

sealed class RestaurantTablesState {}

final class RestaurantTablesInitial extends RestaurantTablesState {}

final class RestaurantTablesLoading extends RestaurantTablesState {}

final class RestaurantTablesLoaded extends RestaurantTablesState {}

final class RestaurantTablesError extends RestaurantTablesState {
  final String message;
  RestaurantTablesError({required this.message});
}

final class RestaurantTablesDeleteError extends RestaurantTablesState {
  final String message;
  RestaurantTablesDeleteError({required this.message});
}
