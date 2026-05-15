import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/calls_history/domain/calls_hisotry_bloc/calls_history_bloc.dart';

class CallHistoryLeadingActions extends StatelessWidget {
  const CallHistoryLeadingActions({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.messageLight : AppColors.messageDark;

    return BlocBuilder<CallsHistoryBloc, CallsHistoryState>(
      builder: (context, state) {
        if (state is CallsHistoryLoaded && state.calls.isEmpty) {
          return const SizedBox(width: 40, height: 40);
        }

        if (state is CallsHistoryLoaded && state.isSelectionMode) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.close, color: baseColor),
                onPressed: () => context
                    .read<CallsHistoryBloc>()
                    .add(CallsHistoryToggleSelectionMode()),
              ),
              if (state.selectedCallIds.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.delete, color: baseColor),
                  onPressed: () => context
                      .read<CallsHistoryBloc>()
                      .add(CallsHistoryDeleteSelected()),
                ),
            ],
          );
        }

        return IconButton(
          icon: SvgPicture.asset(
            'assets/icons/pen.svg',
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(baseColor, BlendMode.srcIn),
          ),
          onPressed: () => context
              .read<CallsHistoryBloc>()
              .add(CallsHistoryToggleSelectionMode()),
        );
      },
    );
  }
}
