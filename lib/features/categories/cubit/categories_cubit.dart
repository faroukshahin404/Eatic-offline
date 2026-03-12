import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/category_model.dart';
import '../repos/offline/categories_offline_repos.dart';

part 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit(this._repository) : super(CategoriesInitial());

  final CategoriesOfflineRepository _repository;

  List<CategoryModel> categories = [];

  Future<void> getAll() async {
    emit(CategoriesLoading());
    final result = await _repository.getAll();
    result.fold(
      (f) => emit(CategoriesError(message: f.failureMessage ?? 'Error')),
      (list) {
        categories = list;
        emit(CategoriesLoaded());
      },
    );
  }

  Future<void> deleteById(int id) async {
    emit(CategoriesLoading());
    final result = await _repository.deleteById(id);
    result.fold(
      (f) => emit(CategoriesDeleteError(message: f.failureMessage ?? 'Error')),
      (_) => getAll(),
    );
  }
}
