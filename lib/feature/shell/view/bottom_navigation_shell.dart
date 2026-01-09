import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/l10n/generated/l10n.dart';

class BottomNavigationShell extends StatelessWidget {
  const BottomNavigationShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (int idx) => _onItemTapped(idx, context),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.contacts),
            label: context.s.contacts,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.call),
            label: context.s.calls,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat),
            label: context.s.chats,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: context.s.settings,
          ),
        ],
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith(Routes.contacts.path)) return 0;
    if (location.startsWith(Routes.calls.path)) return 1;
    if (location.startsWith(Routes.chats.path)) return 2;
    if (location.startsWith(Routes.settings.path)) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(Routes.contacts.path);
        break;
      case 1:
        context.go(Routes.calls.path);
        break;
      case 2:
        context.go(Routes.chats.path);
        break;
      case 3:
        context.go(Routes.settings.path);
        break;
    }
  }
}
