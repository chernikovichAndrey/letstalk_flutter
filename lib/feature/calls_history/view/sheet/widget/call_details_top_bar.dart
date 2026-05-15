import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/call/domain/bloc/call_bloc.dart';
import 'package:lets_talk/feature/calls_history/domain/call_details_cubit/call_details_cubit.dart';

class CallDetailsTopBar extends StatelessWidget {
  final CallDetailsState state;

  const CallDetailsTopBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final closeColor =
        isDark ? AppColors.messageLight : AppColors.messageDark;
    final isLoaded = state is CallDetailsLoaded;

    return Row(
      children: [
        InkResponse(
          onTap: context.pop,
          radius: 22,
          child: SizedBox(
            width: 24,
            height: 24,
            child: Icon(Icons.close, size: 24, color: closeColor),
          ),
        ),
        const Spacer(),
        _actionIcon(
          'assets/icons/phone.svg',
          onTap: isLoaded ? () => _startCall(context, isVideo: false) : null,
        ),
        const SizedBox(width: 12),
        _actionIcon(
          'assets/icons/videocamera.svg',
          onTap: isLoaded ? () => _startCall(context, isVideo: true) : null,
        ),
      ],
    );
  }

  Widget _actionIcon(String asset, {required VoidCallback? onTap}) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: SvgPicture.asset(
        asset,
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(AppColors.brand, BlendMode.srcIn),
      ),
    );
  }

  void _startCall(BuildContext context, {required bool isVideo}) {
    final state = this.state;
    if (state is! CallDetailsLoaded) return;
    final call = state.call;
    context.read<CallBloc>().add(
      CallInitiated(
        targetUserId: call.peer.userId,
        fullName: call.peer.name,
        avatar: call.peer.avatar,
        isVideo: isVideo,
      ),
    );
    context.pop();
  }
}
