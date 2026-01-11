import 'dart:async';
import 'dart:ui';

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
              child: const _CallsAppBar(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallsAppBar extends StatelessWidget {
  const _CallsAppBar();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white : Colors.black;
    final gradientColors = [
      baseColor.withValues(alpha: 0.05),
      baseColor.withValues(alpha: 0.05),
    ];

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Stack(
          children: [
            Positioned.fill(
              child: ShaderMask(
                shaderCallback: (rect) {
                  return const LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.transparent, Colors.black],
                    stops: [0.0, 1.0],
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstIn,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: gradientColors,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: baseColor.withValues(alpha: 0.1),
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
                    unselectedLabelColor: baseColor.withValues(alpha: 0.6),
                    tabs: [
                      Tab(text: context.s.allCalls),
                      Tab(text: context.s.missedCalls),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
