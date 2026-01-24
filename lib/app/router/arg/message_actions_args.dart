import 'package:lets_talk/app/router/arg/router_args.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';

class MessageActionsArgs extends RouterArgs {
  final Message message;
  final bool isMe;

  const MessageActionsArgs({required this.message, required this.isMe});
}