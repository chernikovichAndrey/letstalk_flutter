import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lets_talk/app/environment/environment.dart';
import 'package:lets_talk/app/router/arg/call_details_args.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/feature/calls_history/data/model/call_history_model.dart';
import 'package:lets_talk/feature/calls_history/domain/calls_hisotry_bloc/calls_history_bloc.dart';

class CallHistoryListItem extends StatelessWidget {
  final CallHistory call;
  final bool isSelectionMode;
  final bool isSelected;

  const CallHistoryListItem({
    super.key,
    required this.call,
    this.isSelectionMode = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CAvatar(
        name: call.peer.name,
        imageUrl: call.peer.avatar != null && call.peer.avatar!.isNotEmpty
            ? '${Env.baseUrl}uploads/${call.peer.avatar}'
            : null,
        radius: 24,
      ),
      title: Text(
        call.peer.name.isEmpty ? call.peer.phone : call.peer.name,
        style: theme.textTheme.bodyLarge,
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
      trailing: isSelectionMode
          ? Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected
                  ? context.color.primary
                  : context.color.onSurface.withValues(alpha: 0.3),
            )
          : Row(
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
      onTap: () {
        if (isSelectionMode) {
          context
              .read<CallsHistoryBloc>()
              .add(CallsHistoryToggleCallSelection(call.id));
        } else {
          context.push(
            Routes.callDetails.path,
            extra: CallDetailsArgs(callId: call.id),
          );
        }
      },
    );
  }

  IconData _getDirectionIcon() {
    if (call.status == 'missed') return CupertinoIcons.phone_down_circle;
    if (call.direction == 'outgoing') return CupertinoIcons.phone_arrow_up_right;
    return CupertinoIcons.phone_arrow_down_left;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    
    final now = DateTime.now();
    final localDate = date.toLocal();
    
    // Check if call was this week
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    
    if (localDate.isAfter(startOfWeekDate)) {
      // Show abbreviated day name
      return DateFormat('EE', 'ru').format(localDate);
    }
    
    // Check if call was this year
    if (localDate.year == now.year) {
      // Show day and month (01.12)
      return DateFormat('dd.MM').format(localDate);
    }
    
    // Call was not this year - show day.month.year (01.12.25)
    return DateFormat('dd.MM.yy').format(localDate);
  }
}
