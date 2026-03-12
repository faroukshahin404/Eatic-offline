import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/user_model.dart';
import '../repos/offline/user_offline_repos.dart';

part 'users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  UsersCubit(this.userOfflineRepository) : super(UsersInitial());

  final UserOfflineRepository userOfflineRepository;

  List<UserModel> users = [];

  Future<void> getUsers() async {
    emit(UsersLoading());
    final result = await userOfflineRepository.getAll();
    result.fold((f) => emit(UsersError(message: f.failureMessage ?? 'Error')), (
      users,
    ) {
      this.users = users;
      emit(UsersLoaded());
    });
  }

  Future<void> deleteUser({required int? id}) async {
    emit(UsersLoading());
    final result = await userOfflineRepository.deleteById(id!);
    result.fold(
      (f) => emit(UsersDeletedError(message: f.failureMessage ?? 'Error')),
      (_) {
        getUsers();
      },
    );
  }
}
