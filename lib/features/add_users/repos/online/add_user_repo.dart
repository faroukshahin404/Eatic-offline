import '../../../users/model/user_model.dart';

abstract class AddUserRepo {
  Future<UserModel?> getUserById(int id);
}
