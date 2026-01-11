import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_refreshable_scroll_view.dart';
import 'package:lets_talk/feature/calls/data/model/call_model.dart';
import 'package:lets_talk/feature/calls/domain/calls_bloc/calls_bloc.dart';
import 'package:lets_talk/feature/calls/view/widgets/call_list_item.dart';

class CallList extends StatelessWidget {
  final List<Call> calls;
  final double topPadding;

  const CallList({
    super.key,
    required this.calls,
    this.topPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    return CRefreshableScrollView(
      onRefresh: () async {
        final completer = Completer();
        context.read<CallsBloc>().add(RefreshCalls(completer: completer));
        return completer.future;
      },
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: topPadding)),
        if (calls.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(context.s.noCalls),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final call = calls[index];
                return CallListItem(
                  call: call,
                  onDelete: () {
                    context.read<CallsBloc>().add(DeleteCall(call.id));
                  },
                );
              },
              childCount: calls.length,
            ),
          ),
      ],
    );
  }
}
