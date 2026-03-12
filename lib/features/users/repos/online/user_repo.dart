import '../../model/user_model.dart';

/// Contract for fetching users from a remote source (API).
/// Implement with your HTTP client and map response to [UserModel].
abstract class UserRepo {
  Future<List<UserModel>> getUsers();
  Future<UserModel?> getUserById(int id);
  Future<UserModel?> getUserByCode(String code);
}
