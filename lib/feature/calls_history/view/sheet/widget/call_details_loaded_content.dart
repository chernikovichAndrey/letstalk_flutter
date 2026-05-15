import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/utils/call_details_string_formatter.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/feature/calls_history/domain/call_details_cubit/call_details_cubit.dart';
import 'package:lets_talk/feature/calls_history/view/sheet/widget/call_details_info_card.dart';

class CallDetailsLoadedContent extends StatelessWidget {
  final CallDetailsLoaded state;

  const CallDetailsLoadedContent({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final nameColor =
        isDark ? AppColors.messageLight : const Color(0xFF181619);
    final call = state.call;

    final entries = <MapEntry<String, String>>[
      MapEntry(context.s.phone, call.peer.phone),
      MapEntry(
        context.s.callDirection,
        getDirectionText(context, call.direction),
      ),
      MapEntry(context.s.type, getTypeText(context, call.type)),
      if (call.status == 'ended')
        MapEntry(context.s.duration, getCallDuration(context, call)),
      MapEntry(context.s.date, formatDate(call.startedAt)),
      MapEntry(context.s.status, getStatusText(context, call.status)),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 39),
      child: Column(
        children: [
          CAvatar(
            name: call.peer.name,
            imageUrl: call.peer.avatar,
            radius: 50,
          ),
          const SizedBox(height: 12),
          Text(
            call.peer.name,
            style: AppTypography.headingXsMedium.copyWith(color: nameColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CallDetailsInfoCard(entries: entries),
        ],
      ),
    );
  }
}
