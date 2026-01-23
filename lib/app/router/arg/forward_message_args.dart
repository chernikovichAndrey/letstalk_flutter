import 'package:lets_talk/app/router/arg/router_args.dart';

class ForwardMessageArgs extends RouterArgs {
  final int messageId;
  final int chatId;

  const ForwardMessageArgs({required this.messageId, required this.chatId});
}
