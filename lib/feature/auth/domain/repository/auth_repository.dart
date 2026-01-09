abstract class AuthRepository {
  Future<void> login(String countryCode, String phoneNumber);
}
