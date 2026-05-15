import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/app/router/arg/call_details_args.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/calls_history/domain/call_details_cubit/call_details_cubit.dart';
import 'package:lets_talk/feature/calls_history/view/sheet/widget/call_details_view.dart';

class CallDetailsSheet extends StatelessWidget {
  const CallDetailsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final callId = context.getArgsOrNull<CallDetailsArgs>()!.callId;
        return getIt<CallDetailsCubit>()..loadCallDetails(callId);
      },
      child: const CallDetailsView(),
    );
  }
}
