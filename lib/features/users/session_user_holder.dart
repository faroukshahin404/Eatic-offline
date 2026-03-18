import 'model/user_model.dart';

/// Holds the current logged-in user in memory for the session.
/// Set on login so custody can save createdBy/closedBy when secure storage is empty (e.g. macOS keychain failure).
/// Clear on logout.
abstract class SessionUserHolder {
  static UserModel? _current;

  static UserModel? get current => _current;

  static set current(UserModel? value) {
    _current = value;
  }

  static void clear() {
    _current = null;
  }
}
