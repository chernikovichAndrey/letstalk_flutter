import 'package:lets_talk/feature/calls_history/data/model/call_history_model.dart';

abstract class CallsHistoryRepository {
  Future<List<CallHistory>> getCalls();
  Future<void> deleteCall(int id);
}
