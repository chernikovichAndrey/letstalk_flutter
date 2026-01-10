import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_refreshable_scroll_view.dart';
import 'package:lets_talk/feature/calls/domain/calls_bloc/calls_bloc.dart';
import 'package:lets_talk/feature/calls/view/widgets/call_list.dart';
import 'package:lets_talk/feature/calls/view/widgets/call_list_skeleton.dart';

class CallsPage extends StatelessWidget {
  const CallsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.s.calls),
          toolbarHeight: 30,
          centerTitle: true,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 36,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Theme.of(context).colorScheme.onSurface,
                  unselectedLabelColor:
                      Theme.of(context).colorScheme.onSurfaceVariant,
                  tabs: [
                    Tab(text: context.s.allCalls),
                    Tab(text: context.s.missedCalls),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: BlocBuilder<CallsBloc, CallsState>(
          builder: (context, state) {
            if (state is CallsLoading) {
              return const CallListSkeleton();
            } else if (state is CallsError) {
              return CRefreshableScrollView(
                onRefresh: () async {
                  final completer = Completer();
                  context.read<CallsBloc>().add(RefreshCalls(completer: completer));
                  return completer.future;
                },
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text(state.message)),
                  ),
                ],
              );
            } else if (state is CallsLoaded) {
              return TabBarView(
                children: [
                  CallList(calls: state.calls),
                  CallList(
                    calls: state.calls
                        .where((c) => c.status == 'missed')
                        .toList(),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
