import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_refreshable_scroll_view.dart';
import 'package:lets_talk/feature/calls_history/data/model/call_history_model.dart';
import 'package:lets_talk/feature/calls_history/domain/calls_hisotry_bloc/calls_history_bloc.dart';
import 'package:lets_talk/feature/calls_history/view/widgets/call_history_list_item.dart';

class CallHistoryList extends StatelessWidget {
  final List<CallHistory> calls;
  final double topPadding;
  final bool isSelectionMode;
  final Set<int> selectedCallIds;

  const CallHistoryList({
    super.key,
    required this.calls,
    this.topPadding = 0,
    this.isSelectionMode = false,
    this.selectedCallIds = const {},
  });

  @override
  Widget build(BuildContext context) {
    return CRefreshableScrollView(
      edgeOffset: topPadding,
      onRefresh: () async {
        final completer = Completer();
        context.read<CallsHistoryBloc>().add(
          RefreshHistoryCalls(completer: completer),
        );
        return completer.future;
      },
      slivers: [
        if (calls.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                context.s.noCalls,
                style: AppTypography.textMdMedium.copyWith(
                  color: context.color.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final call = calls[index];
              return CallHistoryListItem(
                call: call,
                isSelectionMode: isSelectionMode,
                isSelected: selectedCallIds.contains(call.id),
              );
            }, childCount: calls.length),
          ),
      ],
    );
  }
}
