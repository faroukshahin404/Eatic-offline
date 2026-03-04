import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/branch_model.dart';
import '../repos/offline/branches_offline_repos.dart';

part 'branches_state.dart';

class BranchesCubit extends Cubit<BranchesState> {
  BranchesCubit(this._repo) : super(BranchesInitial());

  final BranchesOfflineRepository _repo;

  List<BranchModel> branches = [];

  Future<void> getBranches() async {
    emit(BranchesLoading());
    final result = await _repo.getAll();
    result.fold(
      (f) => emit(BranchesError(message: f.failureMessage ?? 'Error')),
      (branches) {
        this.branches = branches;
        emit(BranchesLoaded());
      },
    );
  }

  Future<void> removeBranch(int branchId) async {
    final result = await _repo.remove(branchId);
    result.fold(
      (f) => emit(BranchesError(message: f.failureMessage ?? 'Error')),
      (_) => getBranches(),
    );
  }
}
