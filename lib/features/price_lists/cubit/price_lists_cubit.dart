import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/price_list_model.dart';
import '../repos/offline/price_lists_offline_repos.dart';

part 'price_lists_state.dart';

class PriceListsCubit extends Cubit<PriceListsState> {
  PriceListsCubit(this._repository) : super(PriceListsInitial());

  final PriceListsOfflineRepository _repository;

  List<PriceListModel> priceLists = [];

  Future<void> getAll() async {
    emit(PriceListsLoading());
    final result = await _repository.getAll();
    result.fold(
      (f) => emit(PriceListsError(message: f.failureMessage ?? 'Error')),
      (list) {
        priceLists = list;
        emit(PriceListsLoaded());
      },
    );
  }

  Future<void> deleteById(int id) async {
    emit(PriceListsLoading());
    final result = await _repository.deleteById(id);
    result.fold(
      (f) => emit(PriceListsDeleteError(message: f.failureMessage ?? 'Error')),
      (_) => getAll(),
    );
  }
}
