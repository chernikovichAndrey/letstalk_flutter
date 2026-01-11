import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/widget/c_refreshable_scroll_view.dart';
import 'package:lets_talk/feature/calls/domain/calls_bloc/calls_bloc.dart';
import 'package:lets_talk/feature/calls/view/widgets/call_list.dart';
import 'package:lets_talk/feature/calls/view/widgets/call_list_skeleton.dart';
import 'package:lets_talk/feature/calls/view/widgets/calls_app_bar.dart';

class CallsPage extends StatelessWidget {
  const CallsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + 52;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            BlocBuilder<CallsBloc, CallsState>(
              builder: (context, state) {
                if (state is CallsLoading) {
                  return Padding(
                    padding: EdgeInsets.only(top: topPadding),
                    child: const CallListSkeleton(),
                  );
                } else if (state is CallsError) {
                  return CRefreshableScrollView(
                    onRefresh: () async {
                      final completer = Completer();
                      context.read<CallsBloc>().add(RefreshCalls(completer: completer));
                      return completer.future;
                    },
                    slivers: [
                      SliverToBoxAdapter(child: SizedBox(height: topPadding)),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: Text(state.message)),
                      ),
                    ],
                  );
                } else if (state is CallsLoaded) {
                  return TabBarView(
                    children: [
                      CallList(
                        calls: state.calls,
                        topPadding: topPadding,
                      ),
                      CallList(
                        calls: state.calls
                            .where((c) => c.status == 'missed')
                            .toList(),
                        topPadding: topPadding,
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
              child: const CallsAppBar(),
            ),
          ],
        ),
      ),
    );
  }
}