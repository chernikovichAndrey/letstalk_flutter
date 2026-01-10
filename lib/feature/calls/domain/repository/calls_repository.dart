import 'package:lets_talk/feature/calls/data/model/call_model.dart';

abstract class CallsRepository {
  Future<List<Call>> getCalls();
  Future<void> deleteCall(int id);
}
