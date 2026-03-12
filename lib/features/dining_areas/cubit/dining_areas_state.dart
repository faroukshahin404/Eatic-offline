part of 'dining_areas_cubit.dart';

sealed class DiningAreasState {}

final class DiningAreasInitial extends DiningAreasState {}

final class DiningAreasLoading extends DiningAreasState {}

final class DiningAreasLoaded extends DiningAreasState {}

final class DiningAreasError extends DiningAreasState {
  final String message;
  DiningAreasError({required this.message});
}

final class DiningAreasDeleteError extends DiningAreasState {
  final String message;
  DiningAreasDeleteError({required this.message});
}
