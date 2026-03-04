import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/currency_model.dart';
import '../repos/offline/currencies_offline_repos.dart';

part 'currencies_state.dart';

class CurrenciesCubit extends Cubit<CurrenciesState> {
  CurrenciesCubit(this._repository) : super(CurrenciesInitial());

  final CurrenciesOfflineRepository _repository;

  List<CurrencyModel> currencies = [];

  Future<void> getAll() async {
    emit(CurrenciesLoading());
    final result = await _repository.getAll();
    result.fold(
      (f) => emit(CurrenciesError(message: f.failureMessage ?? 'Error')),
      (list) {
        currencies = list;
        emit(CurrenciesLoaded());
      },
    );
  }

  Future<void> deleteById(int id) async {
    emit(CurrenciesLoading());
    final result = await _repository.deleteById(id);
    result.fold(
      (f) => emit(CurrenciesDeleteError(message: f.failureMessage ?? 'Error')),
      (_) => getAll(),
    );
  }
}
