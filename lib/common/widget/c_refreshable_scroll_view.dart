import 'package:flutter/cupertino.dart';

class CRefreshableScrollView extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final List<Widget> slivers;
  final ScrollPhysics? physics;
  final ScrollController? controller;
  final double edgeOffset;

  const CRefreshableScrollView({
    super.key,
    required this.onRefresh,
    required this.slivers,
    this.physics,
    this.controller,
    this.edgeOffset = 0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      physics: physics ?? const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(top: edgeOffset),
          sliver: CupertinoSliverRefreshControl(
            onRefresh: onRefresh,
          ),
        ),
        ...slivers,
      ],
    );
  }
}
