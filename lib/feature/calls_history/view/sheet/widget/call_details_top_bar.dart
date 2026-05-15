import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/select_call_type_dialog.dart';
import 'package:lets_talk/feature/calls_history/domain/call_details_cubit/call_details_cubit.dart';

class CallDetailsTopBar extends StatelessWidget {
  final CallDetailsState state;

  const CallDetailsTopBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final closeColor =
        isDark ? AppColors.messageLight : AppColors.messageDark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _iconButton(
          onTap: context.pop,
          child: Icon(Icons.close, size: 24, color: closeColor),
        ),
        _iconButton(
          onTap: () => _onCallTap(context),
          child: SvgPicture.asset(
            'assets/icons/phone.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              AppColors.brand,
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
    );
  }

  void _onCallTap(BuildContext context) {
    final state = this.state;
    if (state is! CallDetailsLoaded) return;
    final call = state.call;
    SelectCallTypeDialog(
      call.peer.userId,
      call.peer.name,
      call.peer.avatar,
      context,
    );
  }

  Widget _iconButton({required VoidCallback onTap, required Widget child}) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: SizedBox(width: 24, height: 24, child: Center(child: child)),
    );
  }
}
