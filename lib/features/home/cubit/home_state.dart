import '../../add_new_product/model/product_model.dart';
import '../../categories/model/category_model.dart';

sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeLoaded extends HomeState {
  HomeLoaded({
    required this.categories,
    required this.products,
    required this.selectedCategoryId,
  });
  final List<CategoryModel> categories;
  final List<ProductModel> products;
  /// null means "All" selected
  final int? selectedCategoryId;
}

final class HomeError extends HomeState {
  HomeError(this.message);
  final String message;
}
