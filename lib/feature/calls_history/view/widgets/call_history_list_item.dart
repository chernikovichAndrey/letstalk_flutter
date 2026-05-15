import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lets_talk/app/router/arg/call_details_args.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
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

  bool get _isMissed => call.status == 'missed';
  bool get _isIncoming => call.direction == 'incoming';

  String _iconAsset() {
    if (_isMissed) return 'assets/icons/call_missed.svg';
    if (_isIncoming) return 'assets/icons/call_incoming.svg';
    return 'assets/icons/call_outgoing.svg';
  }

  String _directionText(BuildContext context) {
    if (_isMissed) return context.s.missedCall;
    final base = _isIncoming
        ? context.s.callDirectionIncoming
        : context.s.callDirectionOutgoing;
    if (call.durationFormatted != null && call.durationFormatted!.isNotEmpty) {
      return '$base (${call.durationFormatted})';
    }
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;

    final titleColor = _isMissed
        ? AppColors.error
        : (isDark ? AppColors.messageLight : AppColors.messageDark);
    final subtitleColor = isDark ? AppColors.grayLight : AppColors.grayDark;
    final timeColor = AppColors.grayLight;
    final borderColor = isDark ? AppColors.messageDark : AppColors.messageLight;
    final iconColor = isDark ? AppColors.grayLight : AppColors.grayDark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onTap(context),
        child: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CAvatar(
                name: call.peer.name,
                imageUrl: call.peer.avatar,
                radius: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(
                    right: 16,
                    top: 8,
                    bottom: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: borderColor, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              call.peer.name.isEmpty
                                  ? call.peer.phone
                                  : call.peer.name,
                              style: AppTypography.textMdMedium.copyWith(
                                color: titleColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  _iconAsset(),
                                  width: 16,
                                  height: 16,
                                  colorFilter: ColorFilter.mode(
                                    iconColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _directionText(context),
                                    style: AppTypography.textSmMedium.copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: subtitleColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _Trailing(
                        call: call,
                        isSelectionMode: isSelectionMode,
                        isSelected: isSelected,
                        timeColor: timeColor,
                        iconColor: iconColor,
                        subtitleColor: subtitleColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context) {
    if (isSelectionMode) {
      context.read<CallsHistoryBloc>().add(
        CallsHistoryToggleCallSelection(call.id),
      );
    } else {
      context.push(
        Routes.callDetails.path,
        extra: CallDetailsArgs(callId: call.id),
      );
    }
  }
}

class _Trailing extends StatelessWidget {
  final CallHistory call;
  final bool isSelectionMode;
  final bool isSelected;
  final Color timeColor;
  final Color iconColor;
  final Color subtitleColor;

  const _Trailing({
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
