import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/c_page.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/extension/routes_ext.dart';
import 'package:lets_talk/feature/auth/domain/auth_bloc/auth_bloc.dart';
import 'package:lets_talk/feature/shell/view/bottom_navigation_shell.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final config = GoRouter(
    initialLocation: Routes.contacts.path, // Default to contacts if logged in
    navigatorKey: navigatorKey,
    debugLogDiagnostics: true,
    refreshListenable: _StreamListenable(authBloc.stream),
    redirect: (context, state) {
      final isLoggedIn = authBloc.state is AuthAuthenticated;
      final isLoggingIn = state.uri.path == Routes.login.path;

      if (!isLoggedIn) {
        return isLoggingIn ? null : Routes.login.path;
      }

      if (isLoggingIn) {
        return Routes.contacts.path;
      }

      return null;
    },
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

// Helper to convert Stream to Listenable for GoRouter
class _StreamListenable extends ChangeNotifier {
  final Stream stream;
  _StreamListenable(this.stream) {
    stream.listen((_) => notifyListeners());
  }
}
