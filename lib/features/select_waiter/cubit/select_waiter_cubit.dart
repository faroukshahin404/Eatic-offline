import 'package:flutter_bloc/flutter_bloc.dart';

import '../../users/model/user_model.dart';
import '../../users/repos/offline/user_offline_repos.dart';

part 'select_waiter_state.dart';

class SelectWaiterCubit extends Cubit<SelectWaiterState> {
  SelectWaiterCubit(this._userRepo) : super(SelectWaiterInitial());

  final UserOfflineRepository _userRepo;

  List<UserModel> waiters = [];
  UserModel? selectedWaiter;

  Future<void> getWaiters() async {
    emit(SelectWaiterLoading());
    final result = await _userRepo.getWaiters();
    result.fold(
      (f) => emit(SelectWaiterError(message: f.failureMessage ?? 'Error')),
      (list) {
        waiters = list;
        emit(SelectWaiterLoaded());
      },
    );
  }

  void setSelectedWaiter(UserModel? user) {
    selectedWaiter = user;
    emit(SelectWaiterLoaded());
  }
}
