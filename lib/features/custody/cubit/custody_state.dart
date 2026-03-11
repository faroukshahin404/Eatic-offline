sealed class CustodyState {}

final class CustodyInitial extends CustodyState {}

final class CustodyLoaded extends CustodyState {
  CustodyLoaded(this.custody);
  final dynamic custody;
}

final class CustodyError extends CustodyState {
  CustodyError(this.message);
  final String message;
}

/// State when the amount dialog is open; [amountText] is the current keypad input.
final class CustodyAmountEditing extends CustodyState {
  CustodyAmountEditing(this.amountText);
  final String amountText;
}

/// Emitted when a new custody is created successfully.
final class CustodyCreateSuccess extends CustodyState {
  CustodyCreateSuccess(this.custody);
  final dynamic custody;
}

/// Emitted when a custody is closed successfully.
final class CustodyCloseSuccess extends CustodyState {}

