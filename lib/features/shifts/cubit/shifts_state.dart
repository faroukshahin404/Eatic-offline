import '../../custody/model/custody_model.dart';

abstract class ShiftsState {}

class ShiftsInitial extends ShiftsState {}

class ShiftsLoading extends ShiftsState {}

class ShiftsLoaded extends ShiftsState {
  ShiftsLoaded({required this.custodies, this.from, this.to});

  final List<CustodyModel> custodies;
  final DateTime? from;
  final DateTime? to;
}

class ShiftsError extends ShiftsState {
  ShiftsError(this.message);
  final String message;
}
