import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:lets_talk/common/constants/api_constants.dart';
import 'package:lets_talk/common/service/api_service.dart';
import 'package:lets_talk/feature/auth/domain/repository/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AuthRepositoryImpl extends AuthRepository {
  final ApiService _apiService = ApiService();
  static const String _tokenKey = 'auth_token';
  static const String _didKey = 'device_id';

  @override
  Future<void> sendPhone(String countryCode, String phoneNumber) async {
    await _apiService.post(
      ApiConstants.loginCode,
      data: {
        'phone': '$countryCode$phoneNumber',
      },
    );
  }

  @override
  Future<String> verifyCode(String phone, String code) async {
    final did = await _getDeviceId();
    final formattedPlatform = Platform.operatingSystem;

    final response = await _apiService.post(
      ApiConstants.login,
      data: {
        'phone': phone,
        'confirm_code': code,
        'platform': formattedPlatform,
        'did': did,
      },
    );
    
    final token = response.data['token'] as String;
    await saveToken(token);
    
    return token;
  }

  Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? did = prefs.getString(_didKey);

    if (did == null) {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        did = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        did = iosInfo.identifierForVendor;
      }
      
      // Fallback to UUID if hardware ID is not available
      if (did == null || did.isEmpty) {
        did = const Uuid().v4();
      }
      
      await prefs.setString(_didKey, did);
    }
    
    return did;
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
