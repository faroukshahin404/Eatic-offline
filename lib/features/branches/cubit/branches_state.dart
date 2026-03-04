part of 'branches_cubit.dart';

sealed class BranchesState {}

final class BranchesInitial extends BranchesState {}

final class BranchesLoading extends BranchesState {}

final class BranchesLoaded extends BranchesState {
}

final class BranchesError extends BranchesState {
  BranchesError({required this.message});
  final String message;
}
