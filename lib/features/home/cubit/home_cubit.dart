import 'package:flutter_bloc/flutter_bloc.dart';

import '../../add_new_product/model/product_model.dart';
import '../../categories/model/category_model.dart';
import '../../categories/repos/offline/categories_offline_repos.dart';
import '../../products/repos/offline/products_offline_repos.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._categoriesRepo, this._productsRepo) : super(HomeInitial());

  final CategoriesOfflineRepository _categoriesRepo;
  final ProductsOfflineRepository _productsRepo;

  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];
  int? _selectedCategoryId;

  List<CategoryModel> get categories => _categories;
  List<ProductModel> get products => _products;
  int? get selectedCategoryId => _selectedCategoryId;

  Future<void> loadData() async {
    emit(HomeLoading());
    final catResult = await _categoriesRepo.getAll();
    await catResult.fold(
      (f) async => emit(HomeError(f.failureMessage ?? 'Error')),
      (list) async {
        _categories = list;
        _selectedCategoryId = null;
         getProductById();
      },
    );
  }

  Future<void> getProductById() async {
    final productResult = await _productsRepo.getProductsByCategoryId(null);
    productResult.fold((f) => emit(HomeError(f.failureMessage ?? 'Error')), (
      products,
    ) {
      _products = products;
      emit(
        HomeLoaded(
          categories: _categories,
          products: _products,
          selectedCategoryId: _selectedCategoryId,
        ),
      );
    });
  }

  Future<void> selectCategory(int? categoryId) async {
    if (_selectedCategoryId == categoryId) return;
    _selectedCategoryId = categoryId;
    emit(HomeLoading());
    final result = await _productsRepo.getProductsByCategoryId(categoryId);
    result.fold((f) => emit(HomeError(f.failureMessage ?? 'Error')), (
      products,
    ) {
      _products = products;
      emit(
        HomeLoaded(
          categories: _categories,
          products: _products,
          selectedCategoryId: _selectedCategoryId,
        ),
      );
    });
  }
}
