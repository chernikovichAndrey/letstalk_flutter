import 'package:lets_talk/common/service/api_service.dart';
import 'package:lets_talk/feature/auth/domain/repository/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryImpl extends AuthRepository {
  final ApiService _apiService = ApiService();
  static const String _tokenKey = 'auth_token';

  @override
  Future<void> sendPhone(String countryCode, String phoneNumber) async {
    await _apiService.post(
      '/login/code',
      data: {
        'phone': '$countryCode$phoneNumber',
      },
    );
  }

  @override
  Future<String> verifyCode(String phone, String code) async {
    final response = await _apiService.post(
      '/login/verify',
      data: {
        'phone': phone,
        'code': code,
      },
    );
    return response.data['token'] as String;
  }

  @override
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  @override
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  @override
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
