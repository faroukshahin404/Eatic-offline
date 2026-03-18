import '../../custody/model/custody_model.dart';

abstract class ShiftsState {}

class ShiftsInitial extends ShiftsState {}

class ShiftsLoading extends ShiftsState {}

class ShiftsLoaded extends ShiftsState {
  ShiftsLoaded(this.custodies);
  final List<CustodyModel> custodies;
}

class ShiftsError extends ShiftsState {
  ShiftsError(this.message);
  final String message;
}
