part of 'users_cubit.dart';

sealed class UsersState {}

final class UsersInitial extends UsersState {}

final class UsersLoading extends UsersState {}

final class UsersLoaded extends UsersState {
}

final class UsersError extends UsersState {
  final String message;
  UsersError({required this.message});
}

final class UsersDeletedError extends UsersState {
  final String message;
  UsersDeletedError({required this.message});
}