import 'package:flutter_bloc/flutter_bloc.dart';

import '../../add_new_product/model/product_model.dart';
import '../repos/offline/products_offline_repos.dart';
import 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(this._productRepo) : super(ProductsInitial());

  final ProductsOfflineRepository _productRepo;

  List<ProductModel> _products = [];
  List<ProductModel> get products => _products;

  Future<void> loadProducts() async {
    emit(ProductsLoading());
    final result = await _productRepo.getAllProducts();
    result.fold(
      (f) => emit(ProductsError(f.failureMessage ?? 'Error')),
      (list) {
        _products = list;
        emit(ProductsLoaded());
      },
    );
  }

  Future<void> deleteProduct(int productId) async {
    final result = await _productRepo.deleteProduct(productId);
    result.fold(
      (f) => emit(ProductsDeleteError(f.failureMessage ?? 'Error')),
      (_) => loadProducts(),
    );
  }
}
