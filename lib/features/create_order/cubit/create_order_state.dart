sealed class CreateOrderState {}

final class CreateOrderInitial extends CreateOrderState {}

final class CreateOrderLoading extends CreateOrderState {}

final class CreateOrderError extends CreateOrderState {}

final class CreateOrderProductLoaded extends CreateOrderState {}

final class ClearProductData extends CreateOrderState {}

final class ValidationRequested extends CreateOrderState {}