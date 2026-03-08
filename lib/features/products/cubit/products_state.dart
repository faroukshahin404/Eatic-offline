sealed class ProductsState {}

final class ProductsInitial extends ProductsState {}

final class ProductsLoading extends ProductsState {}

final class ProductsLoaded extends ProductsState {
  ProductsLoaded();
}


final class ProductsError extends ProductsState {
  ProductsError(this.message);
  final String message;
}

final class ProductsDeleteError extends ProductsState {
  ProductsDeleteError(this.message);
  final String message;
}
