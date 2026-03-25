part of 'orders_status_cubit.dart';

sealed class OrdersStatusState {}

final class OrdersStatusInitial extends OrdersStatusState {}

final class OrdersStatusLoading extends OrdersStatusState {}

final class OrdersStatusLoaded extends OrdersStatusState {}

final class OrdersStatusError extends OrdersStatusState {
  OrdersStatusError({required this.message});
  final String message;
}

