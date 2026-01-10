import 'package:lets_talk/common/service/api_service.dart';
import 'package:lets_talk/feature/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl extends AuthRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<void> sendPhone(String countryCode, String phoneNumber) async {
    await _apiService.post(
      '/login/code',
      data: {
        'phone': '$countryCode$phoneNumber',
      },
    );
  }
}
