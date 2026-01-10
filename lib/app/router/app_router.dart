import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/c_page.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/extension/routes_ext.dart';
import 'package:lets_talk/feature/shell/view/bottom_navigation_shell.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  AppRouter();

  late final config = GoRouter(
    initialLocation: Routes.login.path,
    navigatorKey: navigatorKey,
    debugLogDiagnostics: true,
    routes: [
      // Login route (outside shell)
      buildRoute(Routes.login),
      
      // Shell for main tabs
      ShellRoute(
        builder: (context, state, child) {
          return BottomNavigationShell(child: child);
        },
        routes: [
          buildRoute(Routes.contacts),
          buildRoute(Routes.calls),
          buildRoute(Routes.chats),
          buildRoute(Routes.settings),
        ],
      ),

      // Dialogs and Sheets (global)
      ...Routes.sheetRoutes.map(buildRoute),
      ...Routes.dialogRoutes.map(buildRoute),
    ],
  );

  GoRoute buildRoute(Routes e) {
    return GoRoute(
      path: e.path,
      pageBuilder: (final _, final state) => buildPage(e, state),
    );
  }

  Page buildPage(Routes e, GoRouterState state) {
    return CPage(
      type: e.type,
      key: state.pageKey,
      child: e.widget,
    );
  }

  void dispose() {
    config.dispose();
  }
}
