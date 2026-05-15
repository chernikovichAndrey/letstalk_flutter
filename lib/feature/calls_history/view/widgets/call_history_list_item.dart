import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/arg/call_details_args.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/feature/calls_history/data/model/call_history_model.dart';
import 'package:lets_talk/feature/calls_history/domain/calls_hisotry_bloc/calls_history_bloc.dart';
import 'package:lets_talk/feature/calls_history/view/widgets/call_history_list_item_trailing.dart';

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
    final duration = _formatDuration(context);
    if (duration == null) return base;
    return '$base ($duration)';
  }

  int? _durationSeconds() {
    if (call.duration != null && call.duration! > 0) return call.duration;
    if (call.answeredAt != null && call.endedAt != null) {
      final diff = call.endedAt!.difference(call.answeredAt!).inSeconds;
      return diff > 0 ? diff : null;
    }
    return null;
  }

  String? _formatDuration(BuildContext context) {
    final seconds = _durationSeconds();
    if (seconds == null || seconds <= 0) return null;

    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    final h = context.s.hourAbbr;
    final m = context.s.minuteAbbr;
    final s = context.s.secondAbbr;

    if (hours > 0) {
      if (minutes == 0) return '$hours $h';
      return '$hours $h $minutes $m';
    }
    if (minutes > 0) return '$minutes $m';
    return '$secs $s';
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

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;

    final titleColor = _isMissed
        ? AppColors.error
        : (isDark ? AppColors.messageLight : AppColors.messageDark);
    final subtitleColor = isDark ? AppColors.grayLight : AppColors.grayDark;
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
                      CallHistoryListItemTrailing(
                        call: call,
                        isSelectionMode: isSelectionMode,
                        isSelected: isSelected,
                        timeColor: AppColors.grayLight,
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
}
