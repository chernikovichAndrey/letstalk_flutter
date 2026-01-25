import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:lets_talk/common/constants/api_constants.dart';
import 'package:lets_talk/common/service/api_service.dart';
import 'package:lets_talk/feature/settings/data/model/user_model.dart';
import 'package:lets_talk/feature/settings/domain/repository/profile_repository.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ApiService _apiService;

  ProfileRepositoryImpl(this._apiService);

  @override
  Future<UserModel> getProfile() async {
    final response = await _apiService.get(ApiConstants.profile);
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

  @override
  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? birthday,
  }) async {
    final data = <String, dynamic>{};
    
    if (firstName != null) {
      data['first_name'] = firstName;
    }
    if (lastName != null) {
      data['last_name'] = lastName;
    }
    if (birthday != null) {
      data['birthday'] = birthday;
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
