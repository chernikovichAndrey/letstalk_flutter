import 'package:lets_talk/app/router/route_type.dart';

enum Routes {
  login(path: _Paths.login, type: RouteType.page),
  contacts(path: _Paths.contacts, type: RouteType.page),
  calls(path: _Paths.calls, type: RouteType.page),
  chats(path: _Paths.chats, type: RouteType.page),
  settings(path: _Paths.settings, type: RouteType.page),
  // dialogs
  dialog(path: _Paths.dialog, type: RouteType.dialog);

  const Routes({required this.path, required this.type});

  final String path;
  final RouteType type;

  static List<Routes> get pageRoutes =>
      Routes.values.where((e) => e.type == RouteType.page).toList();

  static List<Routes> get sheetRoutes =>
      Routes.values.where((e) => e.type == RouteType.sheet).toList();

  static List<Routes> get dialogRoutes =>
      Routes.values.where((e) => e.type == RouteType.dialog).toList();
}

abstract class _Paths {
  static const String dialog = '/alert';
  static const String login = '/login';
  static const String contacts = '/contacts';
  static const String calls = '/calls';
  static const String chats = '/chats';
  static const String settings = '/settings';
}
