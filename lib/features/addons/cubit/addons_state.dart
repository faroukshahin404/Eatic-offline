part of 'addons_cubit.dart';

sealed class AddonsState {}

final class AddonsInitial extends AddonsState {}

final class AddonsLoading extends AddonsState {}

final class AddonsLoaded extends AddonsState {}

final class AddonsError extends AddonsState {
  final String message;
  AddonsError({required this.message});
}

final class AddonsDeleteError extends AddonsState {
  final String message;
  AddonsDeleteError({required this.message});
}
