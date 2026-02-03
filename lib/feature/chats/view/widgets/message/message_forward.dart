import 'package:flutter/cupertino.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';

class MessageForward extends StatelessWidget {
  final ForwardedFrom? forwardedFrom;

  const MessageForward({super.key, this.forwardedFrom});

  String _forwardFromName({bool? showPhone = true}) {
    if (forwardedFrom?.fromName != null && forwardedFrom!.fromName.isNotEmpty) {
      return forwardedFrom!.fromName;
    }
    if (forwardedFrom?.fromPhone != null &&
        forwardedFrom!.fromPhone!.isNotEmpty) {
      return forwardedFrom!.fromPhone!;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (forwardedFrom == null) return const SizedBox.shrink();
    return SizedBox(
      height: 46,
      child: Stack(
        children: [
          Text(
            context.s.forwardedFrom,
            style: context.text.bodySmall,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
          ),
          Opacity(
            opacity: 0,
            child: Container(
              padding: EdgeInsets.only(left: 20),
              child: Text(_forwardFromName(), style: context.text.bodySmall),
            ),
          ),
          Positioned(
            top: 20,
            child: Row(
              children: [
                CAvatar(radius: 8, name: _forwardFromName(showPhone: false)),
                SizedBox(width: 4),
                Text(
                  _forwardFromName(),
                  style: context.text.bodySmall,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
