import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/dining_area_model.dart';
import '../repos/offline/dining_areas_offline_repos.dart';

part 'dining_areas_state.dart';

class DiningAreasCubit extends Cubit<DiningAreasState> {
  DiningAreasCubit(this._repository) : super(DiningAreasInitial());

  final DiningAreasOfflineRepository _repository;

  List<DiningAreaModel> diningAreas = [];

  Future<void> getAll() async {
    emit(DiningAreasLoading());
    final result = await _repository.getAll();
    result.fold(
      (f) => emit(DiningAreasError(message: f.failureMessage ?? 'Error')),
      (list) {
        diningAreas = list;
        emit(DiningAreasLoaded());
      },
    );
  }

  Future<void> deleteById(int id) async {
    emit(DiningAreasLoading());
    final result = await _repository.deleteById(id);
    result.fold(
      (f) =>
          emit(DiningAreasDeleteError(message: f.failureMessage ?? 'Error')),
      (_) => getAll(),
    );
  }
}
