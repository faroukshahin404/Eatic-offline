import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/zone_model.dart';
import '../repos/offline/zones_offline_repos.dart';

part 'zones_state.dart';

class ZonesCubit extends Cubit<ZonesState> {
  ZonesCubit(this._repository) : super(ZonesInitial());

  final ZonesOfflineRepository _repository;

  List<ZoneModel> zones = [];

  Future<void> getAllZones() async {
    emit(ZonesLoading());
    final result = await _repository.getAllZones();
    result.fold(
      (f) => emit(ZonesError(message: f.failureMessage ?? 'Error')),
      (list) {
        zones = list;
        emit(ZonesLoaded());
      },
    );
  }

  Future<void> deleteById(int id) async {
    emit(ZonesLoading());
    final result = await _repository.deleteById(id);
    result.fold(
      (f) => emit(ZonesDeleteError(message: f.failureMessage ?? 'Error')),
      (_) => getAllZones(),
    );
  }
}
