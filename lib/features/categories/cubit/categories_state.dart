part of 'categories_cubit.dart';

sealed class CategoriesState {}

final class CategoriesInitial extends CategoriesState {}

final class CategoriesLoading extends CategoriesState {}

final class CategoriesLoaded extends CategoriesState {}

final class CategoriesError extends CategoriesState {
  final String message;
  CategoriesError({required this.message});
}

final class CategoriesDeleteError extends CategoriesState {
  final String message;
  CategoriesDeleteError({required this.message});
}
