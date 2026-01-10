import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/calls/data/model/call_model.dart';
import 'package:lets_talk/feature/calls/domain/calls_bloc/calls_bloc.dart';
import 'package:lets_talk/feature/calls/view/widgets/call_list_item.dart';

class CallList extends StatelessWidget {
  final List<Call> calls;

  const CallList({super.key, required this.calls});

  @override
  Widget build(BuildContext context) {
    if (calls.isEmpty) {
      return Center(
        child: Text(context.s.noCalls),
      );
    }
    return ListView.builder(
      itemCount: calls.length,
      itemBuilder: (context, index) {
        final call = calls[index];
        return CallListItem(
          call: call,
          onDelete: () {
            context.read<CallsBloc>().add(DeleteCall(call.id));
          },
        );
      },
    );
  }
}