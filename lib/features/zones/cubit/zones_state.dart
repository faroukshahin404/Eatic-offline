part of 'zones_cubit.dart';

sealed class ZonesState {}

final class ZonesInitial extends ZonesState {}

final class ZonesLoading extends ZonesState {}

final class ZonesLoaded extends ZonesState {}

final class ZonesError extends ZonesState {
  final String message;
  ZonesError({required this.message});
}

final class ZonesDeleteError extends ZonesState {
  final String message;
  ZonesDeleteError({required this.message});
}
