part of 'add_new_branch_cubit.dart';

sealed class AddNewBranchState {}

final class AddNewBranchInitial extends AddNewBranchState {}

final class AddNewBranchLoading extends AddNewBranchState {}

final class AddNewBranchSaved extends AddNewBranchState {
  AddNewBranchSaved({this.id});
  final int? id;
}

final class AddNewBranchError extends AddNewBranchState {
  AddNewBranchError(this.message);
  final String message;
}
