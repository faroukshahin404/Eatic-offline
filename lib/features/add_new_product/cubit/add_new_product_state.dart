part of 'add_new_product_cubit.dart';

sealed class AddNewProductState {}

final class AddNewProductInitial extends AddNewProductState {}

final class AddNewProductLoading extends AddNewProductState {}

final class AddNewProductReady extends AddNewProductState {}

final class AddNewProductSaved extends AddNewProductState {
  final int productId;
  AddNewProductSaved(this.productId);
}

final class AddNewProductError extends AddNewProductState {
  final String message;
  AddNewProductError(this.message);
}
