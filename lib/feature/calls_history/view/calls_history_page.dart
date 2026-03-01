import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_refreshable_scroll_view.dart';
import 'package:lets_talk/feature/calls_history/domain/calls_hisotry_bloc/calls_history_bloc.dart';
import 'package:lets_talk/feature/calls_history/view/widgets/call_history_app_bar.dart';
import 'package:lets_talk/feature/calls_history/view/widgets/call_history_list.dart';
import 'package:lets_talk/feature/calls_history/view/widgets/call_history_list_skeleton.dart';

class CallsHistoryPage extends StatelessWidget {
  const CallsHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = context.padding.top + 42;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
          BlocBuilder<CallsHistoryBloc, CallsHistoryState>(
            builder: (context, state) {
              if (state is CallsHistoryLoading ||
                  state is CallsHistoryActionInProgress) {
                return Padding(
                  padding: EdgeInsets.only(top: topPadding),
                  child: const CallHistoryListSkeleton(),
                );
              } else if (state is CallsHistoryError) {
                  return CRefreshableScrollView(
                    edgeOffset: topPadding,
                    onRefresh: () async {
                      final completer = Completer();
                      context.read<CallsHistoryBloc>().add(RefreshHistoryCalls(completer: completer));
                      return completer.future;
                    },
                    slivers: [

                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: Text(state.message)),
                      ),
                    ],
                  );
                } else if (state is CallsHistoryLoaded) {
                  return TabBarView(
                    children: [
                      CallHistoryList(
                        calls: state.calls,
                        topPadding: topPadding,
                        isSelectionMode: state.isSelectionMode,
                        selectedCallIds: state.selectedCallIds,
                      ),
                      CallHistoryList(
                        calls: state.calls
                            .where((c) => c.status == 'missed')
                            .toList(),
                        topPadding: topPadding,
                        isSelectionMode: state.isSelectionMode,
                        selectedCallIds: state.selectedCallIds,
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: const CallHistoryAppBar(),
            ),
          ],
        ),
      ),
    );
  }
}