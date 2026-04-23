part of 'shift_details_cubit.dart';

sealed class ShiftDetailsState {}

final class ShiftDetailsInitial extends ShiftDetailsState {}

final class ShiftDetailsLoading extends ShiftDetailsState {}

final class ShiftDetailsLoaded extends ShiftDetailsState {
  ShiftDetailsLoaded({required this.report, required this.receiptPreview});

  final CustodyReviewReportModel report;
  final String receiptPreview;
}

final class ShiftDetailsError extends ShiftDetailsState {
  final String message;
  ShiftDetailsError({required this.message});
}

final class ShiftDetailsPrinting extends ShiftDetailsState {
  ShiftDetailsPrinting({required this.report, required this.receiptPreview});

  final CustodyReviewReportModel report;
  final String receiptPreview;
}
