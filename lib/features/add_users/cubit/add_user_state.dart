part of 'add_user_cubit.dart';

sealed class AddUserState {}

final class AddUserInitial extends AddUserState {}

final class AddUserLoading extends AddUserState {}

final class AddUserLoaded extends AddUserState {
}

final class AddUserError extends AddUserState {
  AddUserError(this.message);
  final String message;
}

final class AddUserSaved extends AddUserState {
  AddUserSaved({this.id});
  final int? id;
}
