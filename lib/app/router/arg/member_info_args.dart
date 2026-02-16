import 'package:lets_talk/app/router/arg/router_args.dart';
import 'package:lets_talk/feature/chats/data/model/chat_model.dart';

class MemberInfoArgs extends RouterArgs {
  final MemberInfo memberInfo;

  const MemberInfoArgs({
    required this.memberInfo,
  });
}