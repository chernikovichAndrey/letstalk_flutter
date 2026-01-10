import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class BottomNavigationShell extends StatelessWidget {
  const BottomNavigationShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (int idx) => _onItemTapped(idx, context),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF50A7EA),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
          unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.person_circle),
              activeIcon: const Icon(CupertinoIcons.person_circle_fill),
              label: context.s.contacts,
            ),
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.phone),
              activeIcon: const Icon(CupertinoIcons.phone_fill),
              label: context.s.calls,
            ),
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.chat_bubble_2),
              activeIcon: const Icon(CupertinoIcons.chat_bubble_2_fill),
              label: context.s.chats,
            ),
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.settings),
              activeIcon: const Icon(CupertinoIcons.settings_solid),
              label: context.s.settings,
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index, BuildContext context) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
