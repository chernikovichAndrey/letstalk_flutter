import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/c_page.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/extension/routes_ext.dart';
import 'package:lets_talk/feature/chats/view/chat_details_page_scope.dart';
import 'package:lets_talk/feature/shell/view/bottom_navigation_shell.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  AppRouter();

  late final config = GoRouter(
    initialLocation: Routes.splash.path,
    navigatorKey: navigatorKey,
    debugLogDiagnostics: true,
    routes: [
      // Splash route
      buildRoute(Routes.splash),
      
      // Login route (outside shell)
      buildRoute(Routes.login),
      
      // Shell for main tabs
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return BottomNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(routes: [buildRoute(Routes.contacts)]),
          StatefulShellBranch(routes: [buildRoute(Routes.calls)]),
          StatefulShellBranch(routes: [buildRoute(Routes.chats)]),
          StatefulShellBranch(routes: [buildRoute(Routes.settings)]),
        ],
      ),

      // Chat Details
      buildRoute(Routes.chatDetails),

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
    if (e == Routes.chatDetails) {
      final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
      return CPage(
        type: e.type,
        key: state.pageKey,
        child: ChatDetailsPageScope(chatId: id),
      );
    }
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
