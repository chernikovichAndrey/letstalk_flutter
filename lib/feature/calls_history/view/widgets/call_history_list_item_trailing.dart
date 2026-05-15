import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lets_talk/app/router/arg/call_details_args.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/feature/calls_history/data/model/call_history_model.dart';

class CallHistoryListItemTrailing extends StatelessWidget {
  final CallHistory call;
  final bool isSelectionMode;
  final bool isSelected;
  final Color timeColor;
  final Color iconColor;
  final Color subtitleColor;

  const CallHistoryListItemTrailing({
    super.key,
    required this.call,
    required this.isSelectionMode,
    required this.isSelected,
    required this.timeColor,
    required this.iconColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isSelectionMode) {
      return Icon(
        isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
        color: isSelected
            ? AppColors.brand
            : subtitleColor.withValues(alpha: 0.3),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatDate(call.endedAt ?? call.startedAt),
          style: AppTypography.textXsRegular.copyWith(color: timeColor),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => context.push(
            Routes.callDetails.path,
            extra: CallDetailsArgs(callId: call.id),
          ),
          behavior: HitTestBehavior.opaque,
          child: SvgPicture.asset(
            'assets/icons/info_circle.svg',
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final localDate = date.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(localDate.year, localDate.month, localDate.day);

    if (dateOnly == today) {
      return DateFormat('HH:mm').format(localDate);
    }

    final startOfWeek = today.subtract(Duration(days: now.weekday - 1));
    if (dateOnly.isAfter(startOfWeek.subtract(const Duration(days: 1)))) {
      return DateFormat('EE', 'ru').format(localDate);
    }

    if (localDate.year == now.year) {
      return DateFormat('dd.MM').format(localDate);
    }

    return DateFormat('dd.MM.yy').format(localDate);
  }
}
