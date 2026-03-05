import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/addon_model.dart';
import '../repos/offline/addons_offline_repos.dart';

part 'addons_state.dart';

class AddonsCubit extends Cubit<AddonsState> {
  AddonsCubit(this._repository) : super(AddonsInitial());

  final AddonsOfflineRepository _repository;

  List<AddonModel> addons = [];

  Future<void> getAll() async {
    emit(AddonsLoading());
    final result = await _repository.getAll();
    result.fold(
      (f) => emit(AddonsError(message: f.failureMessage ?? 'Error')),
      (list) {
        addons = list;
        emit(AddonsLoaded());
      },
    );
  }

  Future<void> deleteById(int id) async {
    emit(AddonsLoading());
    final result = await _repository.deleteById(id);
    result.fold(
      (f) => emit(AddonsDeleteError(message: f.failureMessage ?? 'Error')),
      (_) => getAll(),
    );
  }
}
