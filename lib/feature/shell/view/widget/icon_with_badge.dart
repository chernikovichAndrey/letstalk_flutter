import 'package:flutter/material.dart';

class IconWithBudge extends StatelessWidget {
  final int count;
  final Widget icon;

  const IconWithBudge({super.key, required this.count, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Badge(
      label: Text('$count'),
      child: icon,
    );
  }
}