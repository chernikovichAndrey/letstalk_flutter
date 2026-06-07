import 'package:lets_talk/feature/settings/data/model/user_model.dart';

abstract class AuthRepository {
  Future<void> sendPhone(String countryCode, String phoneNumber);
  Future<({String token, bool isNewUser})> verifyCode(String phone, String code);
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
  Future<void> updateFcmToken(String fcmToken, String platform);
  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
  });
  Future<void> updateAvatar(String avatarPath);
}
