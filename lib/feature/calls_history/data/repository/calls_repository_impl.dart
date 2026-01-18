import 'package:lets_talk/common/constants/api_constants.dart';
import 'package:lets_talk/common/service/api_service.dart';
import 'package:lets_talk/feature/calls_history/data/model/call_history_model.dart';
import 'package:lets_talk/feature/calls_history/domain/repository/calls_history_repository.dart';

class CallsRepositoryImpl implements CallsHistoryRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<List<CallHistory>> getCalls() async {
    final response = await _apiService.get(ApiConstants.calls);
    final List<dynamic> callsJson = response.data['calls_history'];
    return callsJson.map((json) => CallHistory.fromJson(json)).toList();
  }

  @override
  Future<void> deleteCall(int id) async {
    await _apiService.delete('${ApiConstants.calls}/$id');
  }
}
