import 'package:lets_talk/feature/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl extends AuthRepository {
  @override
  Future<void> login(String countryCode, String phoneNumber) async {
    // Stub implementation
    await Future.delayed(const Duration(seconds: 1));
  }
}
