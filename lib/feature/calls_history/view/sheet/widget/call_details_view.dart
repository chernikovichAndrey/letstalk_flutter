import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/calls_history/domain/call_details_cubit/call_details_cubit.dart';
import 'package:lets_talk/feature/calls_history/view/sheet/widget/call_details_body.dart';
import 'package:lets_talk/feature/calls_history/view/sheet/widget/call_details_top_bar.dart';

class CallDetailsView extends StatelessWidget {
  const CallDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: BlocBuilder<CallDetailsCubit, CallDetailsState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CallDetailsTopBar(state: state),
                    Expanded(child: CallDetailsBody(state: state)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
