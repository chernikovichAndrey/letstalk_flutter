abstract class AuthRepository {
  Future<void> sendPhone(String countryCode, String phoneNumber);
}
