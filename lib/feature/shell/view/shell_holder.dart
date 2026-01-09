import 'package:flutter/material.dart';

/// parent widget below material app so it supports material features like
/// overlays, themes, etc.
class ShellHolder extends StatelessWidget {
  const ShellHolder({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Scaffold(
        body: SafeArea(
          child: child,
        ),
      ),
    );
  }
}
