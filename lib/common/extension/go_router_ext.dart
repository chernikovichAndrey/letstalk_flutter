import 'package:go_router/go_router.dart';

extension GoRouterExt on GoRouter {
  // fyi https://github.com/flutter/flutter/issues/129833#issuecomment-1725216727
  Uri location() {
    final fullPath = routerDelegate.state.fullPath;
    if (fullPath == null || fullPath.isEmpty) return Uri();
    return Uri.parse(fullPath);
  }
}
