import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/restaurant_table_model.dart';
import '../repos/offline/restaurant_tables_offline_repos.dart';

part 'restaurant_tables_state.dart';

class RestaurantTablesCubit extends Cubit<RestaurantTablesState> {
  RestaurantTablesCubit(this._repository) : super(RestaurantTablesInitial());

  final RestaurantTablesOfflineRepository _repository;

  List<RestaurantTableModel> restaurantTables = [];

  Future<void> getAll() async {
    emit(RestaurantTablesLoading());
    final result = await _repository.getAll();
    result.fold(
      (f) => emit(RestaurantTablesError(message: f.failureMessage ?? 'Error')),
      (list) {
        restaurantTables = list;
        emit(RestaurantTablesLoaded());
      },
    );
  }

  Future<void> deleteById(int id) async {
    emit(RestaurantTablesLoading());
    final result = await _repository.deleteById(id);
    result.fold(
      (f) => emit(RestaurantTablesDeleteError(
          message: f.failureMessage ?? 'Error')),
      (_) => getAll(),
    );
  }
}
