import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/c_page.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/extension/routes_ext.dart';
import 'package:lets_talk/feature/shell/view/bottom_navigation_shell.dart';
import 'package:lets_talk/feature/shell/view/shell_holder.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  AppRouter();

  late final config = GoRouter(
    initialLocation: Routes.splash.path,
    navigatorKey: navigatorKey,
    debugLogDiagnostics: true,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return ShellHolder(child: child);
        },
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
              StatefulShellBranch(routes: [buildRoute(Routes.callsHistory)]),
              StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: Routes.chats.path,
                      pageBuilder: (final _, final state) =>
                          buildPage(Routes.chats, state),
                      routes: [
                        GoRoute(
                          path: Routes.chatDetails.path,
                          parentNavigatorKey: navigatorKey,
                          pageBuilder: (context, state) =>
                              buildPage(Routes.chatDetails, state),
                        )
                      ],
                    )
                  ]),
              StatefulShellBranch(routes: [buildRoute(Routes.settings)]),
            ],
          ),
        ]
      ),

      buildRoute(Routes.call),
      buildRoute(Routes.photoEditor),
      buildRoute(Routes.createChatGroup),

      //Sheets
      ...Routes.sheetRoutes.map(buildRoute),
      // Dialogs(global)
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
