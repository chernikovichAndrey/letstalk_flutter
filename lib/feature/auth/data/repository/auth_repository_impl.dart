import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:lets_talk/common/constants/api_constants.dart';
import 'package:lets_talk/common/service/api_service.dart';
import 'package:lets_talk/feature/auth/domain/repository/auth_repository.dart';
import 'package:lets_talk/feature/settings/data/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl extends AuthRepository {
  final ApiService _apiService;
  static const String _tokenKey = 'auth_token';
  static const String _didKey = 'device_id';

  AuthRepositoryImpl(this._apiService);

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
  Future<({String token, bool isNewUser})> verifyCode(String phone, String code) async {
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
    final isNewUser = response.data['new_user'] == true || response.data['new_user'] == 1;
    await saveToken(token);
    
    return (token: token, isNewUser: isNewUser);
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

  @override
  Future<void> updateFcmToken(String fcmToken, String platform) async {
    await _apiService.post(
      ApiConstants.updateFcmToken,
      data: {
        'fcm_token': fcmToken,
        'platform': platform,
      },
    );
  }

  @override
  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
  }) async {
    final data = <String, dynamic>{};

    if (firstName != null) {
      data['first_name'] = firstName;
    }
    if (lastName != null) {
      data['last_name'] = lastName;
    }

    final response = await _apiService.put(
      ApiConstants.profile,
      data: data,
      options: Options(
        contentType: Headers.jsonContentType,
      ),
    );

    return UserModel.fromJson(response.data['user']);
  }

  @override
  Future<void> updateAvatar(String avatarPath) async {
    final file = File(avatarPath);
    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);

    final extension = avatarPath.split('.').last.toLowerCase();
    final mimeType = _getMimeType(extension);

    final avatarBase64 = '$mimeType;base64,$base64Image';

    await _apiService.post(
      ApiConstants.profileAvatar,
      data: {'avatar_base64': avatarBase64},
      options: Options(
        contentType: Headers.jsonContentType,
      ),
    );
  }

  String _getMimeType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
