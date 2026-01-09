import 'package:flutter/material.dart';
import 'package:lets_talk/app/router/c_page.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/extension/routes_ext.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/feature/shell/view/shell_holder.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  late final config = GoRouter(
    initialLocation: Routes.login.path,
    navigatorKey: navigatorKey,
    debugLogDiagnostics: true,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return ShellHolder(child: child);
        },
        routes: [
          ...Routes.pageRoutes.map(buildRoute),
        ],
      ),
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
