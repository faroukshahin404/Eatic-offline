part of 'login_cubit.dart';

sealed class LoginState {}

final class LoginInitial extends LoginState {}

final class LoginLoading extends LoginState {}

final class LoginSuccess extends LoginState {
  LoginSuccess(this.user);
  final UserModel user;
}

final class LoginError extends LoginState {
  LoginError(this.message);
  final String message;
}
