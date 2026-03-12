part of 'select_table_cubit.dart';

sealed class SelectTableState {}

final class SelectTableInitial extends SelectTableState {}

final class SelectTableLoading extends SelectTableState {}

final class SelectTableLoaded extends SelectTableState {}

final class SelectTableError extends SelectTableState {
  final String message;
  SelectTableError({required this.message});
}
