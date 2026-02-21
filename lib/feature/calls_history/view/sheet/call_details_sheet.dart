import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/app/router/arg/call_details_args.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/utils/call_details_string_formatter.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/common/widget/glass_button.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/calls_history/domain/call_details_cubit/call_details_cubit.dart';

import 'package:lets_talk/common/widget/select_call_type_dialog.dart';
import 'package:lets_talk/feature/calls_history/view/widgets/call_details_info_row.dart';

class CallDetailsSheet extends StatelessWidget {
  const CallDetailsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final callId = context.getArgsOrNull<CallDetailsArgs>()!.callId;
        return getIt<CallDetailsCubit>()..loadCallDetails(callId);
      },
      child: const _CallDetailsView(),
    );
  }
}

class _CallDetailsView extends StatelessWidget {
  const _CallDetailsView();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Scaffold(
        backgroundColor: context.appColors.surfaceSecondary,
        appBar: AppBar(
          backgroundColor: context.appColors.surfaceSecondary,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: GlassButton(icon: Icons.close, onTap: context.pop),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GlassButton(
                icon: Icons.call,
                onTap: () {
                  final state = context.read<CallDetailsCubit>().state;
                  if (state is CallDetailsLoaded) {
                    SelectCallTypeDialog(
                      state.call.peer.userId,
                      state.call.peer.name,
                      state.call.peer.avatar,
                      context,
                    );
                  }
                },
              ),
            ),
          ],
        ),
        body: BlocBuilder<CallDetailsCubit, CallDetailsState>(
          builder: (context, state) {
            if (state is CallDetailsLoading) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (state is CallDetailsError) {
              return SizedBox(
                height: 200,
                child: Center(
                  child: Text(context.s.errorMessage(state.message)),
                ),
              );
            } else if (state is CallDetailsLoaded) {
              final call = state.call;
              final Iterable<MapEntry<String, String>> details = [
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
              return Column(
                children: [
                  CAvatar(
                    name: call.peer.name,
                    imageUrl: call.peer.avatar,
                    radius: 40,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    call.peer.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 0,
                    color: context.appColors.secondaryBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          for (final entry in details) ...[
                            CallDetailsInfoRow(
                              label: entry.key,
                              value: entry.value,
                            ),
                            if (entry.key != context.s.status) const Divider(),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            }
            return const SizedBox(height: 200);
          },
        ),
      ),
    );
  }
}
