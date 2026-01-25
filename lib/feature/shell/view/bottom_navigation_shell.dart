import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/shell/domain/navigation_bloc/navigation_bloc.dart';
import 'package:lets_talk/feature/shell/view/widget/icon_with_badge.dart';

class BottomNavigationShell extends StatelessWidget {
  const BottomNavigationShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
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
                  icon: IconWithBudge(
                    icon: const Icon(CupertinoIcons.phone),
                    count: state.missedCallsCount,
                  ),
                  activeIcon: IconWithBudge(
                    icon: const Icon(CupertinoIcons.phone_fill),
                    count: state.missedCallsCount,
                  ),
                  label: context.s.calls,
                ),
                BottomNavigationBarItem(
                  icon: IconWithBudge(
                    icon: const Icon(CupertinoIcons.chat_bubble_2),
                    count: state.unreadChatsCount,
                  ),
                  activeIcon: IconWithBudge(
                    icon: const Icon(CupertinoIcons.chat_bubble_2_fill),
                    count: state.unreadChatsCount,
                  ),
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
      },
    );
  }

  void _onItemTapped(int index, BuildContext context) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
