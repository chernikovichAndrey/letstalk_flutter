import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/feature/calls_history/data/model/call_history_model.dart';

class CallHistoryListItem extends StatelessWidget {
  final CallHistory call;

  const CallHistoryListItem({
    super.key,
    required this.call,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CAvatar(
        name: call.peer.name,
        radius: 24,
      ),
      title: Text(
        call.peer.name,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            _getDirectionIcon(),
            size: 14,
            color: Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            call.direction == 'incoming' && call.durationFormatted != null
                ? '${call.direction} (${call.durationFormatted})'
                : call.direction,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatDate(call.endedAt ?? call.startedAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(CupertinoIcons.info, color: Colors.blue),
        ],
      ),
    );
  }

  IconData _getDirectionIcon() {
    if (call.status == 'missed') return CupertinoIcons.phone_down_circle;
    if (call.direction == 'outgoing') return CupertinoIcons.phone_arrow_up_right;
    return CupertinoIcons.phone_arrow_down_left;
  }

  String _formatDate(DateTime? date) {
    return DateFormat('dd/MM/yyyy').format(date ?? DateTime.now());
  }
}
