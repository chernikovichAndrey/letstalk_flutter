import 'package:lets_talk/common/constants/api_constants.dart';
import 'package:lets_talk/common/service/api_service.dart';
import 'package:lets_talk/feature/calls/data/model/call_model.dart';
import 'package:lets_talk/feature/calls/domain/repository/calls_repository.dart';

class CallsRepositoryImpl implements CallsRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<List<Call>> getCalls() async {
    final response = await _apiService.get(ApiConstants.calls);
    final List<dynamic> callsJson = response.data['calls'];
    return callsJson.map((json) => Call.fromJson(json)).toList();
  }

  @override
  Future<void> deleteCall(int id) async {
    await _apiService.delete('${ApiConstants.calls}/$id');
  }
}
