import 'package:flutter/cupertino.dart';

class CRefreshableScrollView extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final List<Widget> slivers;
  final ScrollPhysics? physics;
  final ScrollController? controller;

  const CRefreshableScrollView({
    super.key,
    required this.onRefresh,
    required this.slivers,
    this.physics,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      physics: physics ?? const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: onRefresh,
        ),
        ...slivers,
      ],
    );
  }
}
