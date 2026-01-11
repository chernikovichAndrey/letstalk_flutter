import 'package:lets_talk/common/constants/api_constants.dart';
import 'package:lets_talk/common/service/api_service.dart';
import 'package:lets_talk/feature/settings/data/model/user_model.dart';
import 'package:lets_talk/feature/settings/domain/repository/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<UserModel> getProfile() async {
    final response = await _apiService.get(ApiConstants.profile);
    return UserModel.fromJson(response.data['user']);
  }
}
