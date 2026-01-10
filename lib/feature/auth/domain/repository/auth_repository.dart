abstract class AuthRepository {
  Future<void> sendPhone(String countryCode, String phoneNumber);
  Future<String> verifyCode(String phone, String code);
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
}
