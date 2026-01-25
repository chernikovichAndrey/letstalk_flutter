import 'package:lets_talk/feature/settings/data/model/user_model.dart';

abstract class ProfileRepository {
  Future<UserModel> getProfile();
  Future<void> updateAvatar(String avatarPath);
}