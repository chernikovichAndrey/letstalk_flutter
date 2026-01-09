import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/arg/dialog_args.dart';
import 'package:lets_talk/app/router/arg/router_args.dart';
import 'package:lets_talk/app/router/routes.dart';

extension BuildContextRouterExt on BuildContext {
  GoRouter get router => GoRouter.of(this);

  /// Use [GoRouterState.extra] to pass args.
  T? getArgsOrNull<T extends RouterArgs>() {
    final maybeExtra = router.state.extra;
    if (maybeExtra is! T) return null;
    return maybeExtra;
  }

  Future<T?> push<T>(Routes route, {RouterArgs? args}) {
    return router.push<T>(route.path, extra: args);
  }

  Future<void> pushDialog(
    DialogArgs args, {
    VoidCallback? onTrue,
    VoidCallback? onFalse,
  }) async {
    final result = await router.push<bool>(Routes.dialog.path, extra: args);
    if (result == true) {
      onTrue?.call();
      return;
    }
    onFalse?.call();
  }

  void pop<T>([T? result]) {
    return router.pop(result);
  }

  void replace(Routes route, {RouterArgs? args}) {
    return router.go(route.path, extra: args);
  }

  void replaceStack(List<Routes> routes) {
    assert(routes.isNotEmpty, 'routes must not be empty');

    router.go(routes.first.path);

    for (int i = 1; i < routes.length; i++) {
      router.push(routes[i].path);
    }
  }

  void replaceStackWithArgs(List<({Routes route, RouterArgs? args})> routes) {
    if (routes.isEmpty) return;

    // Navigate to the first route
    router.go(routes.first.route.path, extra: routes.first.args);

    // Push remaining routes to the stack
    for (int i = 1; i < routes.length; i++) {
      router.push(routes[i].route.path, extra: routes[i].args);
    }
  }

  bool get canPop => Navigator.canPop(this);
}
