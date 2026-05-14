import 'dart:ui';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/shell/domain/navigation_bloc/navigation_bloc.dart';
import 'package:lets_talk/feature/shell/view/widget/icon_with_badge.dart';

class BottomNavigationShell extends StatefulWidget {
  const BottomNavigationShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<BottomNavigationShell> createState() => _BottomNavigationShellState();
}

class _BottomNavigationShellState extends State<BottomNavigationShell> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getIt<NavigationBloc>().add(NavigationInitEvent());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark 
        ? const Color.fromRGBO(30, 30, 30, 0.8) 
        : const Color.fromRGBO(250, 250, 250, 0.8);
    final borderColor = isDark 
        ? Colors.white10 
        : const Color(0xFFF1F1F1);

    return BlocConsumer<NavigationBloc, NavigationState>(
      listener: (context, state) {
        AppBadgePlus.updateBadge(state.unreadChatsCount);
      },
      builder: (context, state) {
        return Scaffold(
          extendBody: true,
          body: widget.navigationShell,
          bottomNavigationBar: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12.5, sigmaY: 12.5),
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border(
                    top: BorderSide(color: borderColor, width: 1.0),
                  ),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  child: BottomNavigationBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    currentIndex: widget.navigationShell.currentIndex,
                    onTap: (int idx) => _onItemTapped(idx, context),
                    type: BottomNavigationBarType.fixed,
                    selectedItemColor: const Color(0xFFC96A3A),
                    unselectedItemColor: const Color(0xFFBEBEBE),
                    selectedLabelStyle: const TextStyle(
                      fontSize: 12, 
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 12, 
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                    items: [
                      BottomNavigationBarItem(
                        icon: SvgPicture.asset(
                          'assets/icons/nav_contact_unselected.svg', 
                          width: 24, 
                          height: 24,
                        ),
                        activeIcon: SvgPicture.asset(
                          'assets/icons/nav_contact_selected.svg', 
                          width: 24, 
                          height: 24,
                        ),
                        label: context.s.contacts,
                      ),
                      BottomNavigationBarItem(
                        icon: IconWithBudge(
                          icon: SvgPicture.asset(
                            'assets/icons/nav_call_unselected.svg', 
                            width: 24, 
                            height: 24,
                          ),
                          count: state.missedCallsCount,
                        ),
                        activeIcon: IconWithBudge(
                          icon: SvgPicture.asset(
                            'assets/icons/nav_call_selected.svg', 
                            width: 24, 
                            height: 24,
                          ),
                          count: state.missedCallsCount,
                        ),
                        label: context.s.calls,
                      ),
                      BottomNavigationBarItem(
                        icon: IconWithBudge(
                          icon: SvgPicture.asset(
                            'assets/icons/nav_chat_unselected.svg', 
                            width: 24, 
                            height: 24,
                          ),
                          count: state.unreadChatsCount,
                        ),
                        activeIcon: IconWithBudge(
                          icon: SvgPicture.asset(
                            'assets/icons/nav_chat_selected.svg', 
                            width: 24, 
                            height: 24,
                          ),
                          count: state.unreadChatsCount,
                        ),
                        label: context.s.chats,
                      ),
                      BottomNavigationBarItem(
                        icon: SvgPicture.asset(
                          'assets/icons/nav_settings_unselected.svg', 
                          width: 24, 
                          height: 24,
                        ),
                        activeIcon: SvgPicture.asset(
                          'assets/icons/nav_settings_selected.svg', 
                          width: 24, 
                          height: 24,
                        ),
                        label: context.s.settings,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onItemTapped(int index, BuildContext context) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
}