import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/calls_history/domain/call_details_cubit/call_details_cubit.dart';
import 'package:lets_talk/feature/calls_history/view/sheet/widget/call_details_loaded_content.dart';

class CallDetailsBody extends StatelessWidget {
  final CallDetailsState state;

  const CallDetailsBody({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final state = this.state;
    if (state is CallDetailsLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is CallDetailsError) {
      return Center(child: Text(context.s.errorMessage(state.message)));
    }
    if (state is CallDetailsLoaded) {
      return CallDetailsLoadedContent(state: state);
    }
    return const SizedBox.shrink();
  }
}
