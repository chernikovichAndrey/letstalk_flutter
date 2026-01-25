import 'package:lets_talk/app/router/route_type.dart';

enum Routes {
  splash(path: _Paths.splash, type: RouteType.page),
  login(path: _Paths.login, type: RouteType.page),
  contacts(path: _Paths.contacts, type: RouteType.page),
  callsHistory(path: _Paths.callsHistory, type: RouteType.page),
  chats(path: _Paths.chats, type: RouteType.page),
  settings(path: _Paths.settings, type: RouteType.page),
  chatDetails(path: _Paths.chatDetails, type: RouteType.page),
  call(path: _Paths.call, type: RouteType.page),
  // dialogs
  dialog(path: _Paths.dialog, type: RouteType.dialog),
  // sheets
  createContact(path: _Paths.createContact, type: RouteType.sheet),
  callContacts(path: _Paths.callContacts, type: RouteType.sheet),
  chatContacts(path: _Paths.chatContacts, type: RouteType.sheet),
  callDetails(path: _Paths.callDetails, type: RouteType.sheet),
  forwardMessage(path: _Paths.forwardMessage, type: RouteType.sheet),
  fullScreenMedia(path: _Paths.fullScreenMedia, type: RouteType.sheet),
  chatAttachSheet(path: _Paths.chatAttachSheet, type: RouteType.bottomSheet),
  profileAvatarSheet(path: _Paths.profileAvatarSheet, type: RouteType.bottomSheet),
  photoEditor(path: _Paths.photoEditor, type: RouteType.page);

  const Routes({required this.path, required this.type});

  final String path;
  final RouteType type;

  static List<Routes> get pageRoutes =>
      Routes.values.where((e) => e.type == RouteType.page).toList();

  static List<Routes> get sheetRoutes =>
      Routes.values.where((e) =>
        e.type == RouteType.sheet ||
        e.type == RouteType.bottomSheet
      ).toList();

  static List<Routes> get dialogRoutes =>
      Routes.values.where((e) => e.type == RouteType.dialog).toList();
}

abstract class _Paths {
  static const String splash = '/splash';
  static const String dialog = '/alert';
  static const String login = '/login';
  static const String contacts = '/contacts';
  static const String createContact = '/create_contact';
  static const String callContacts = '/call_contacts';
  static const String chatContacts = '/chat_contacts';
  static const String callDetails = '/call_details/:id';
  static const String forwardMessage = '/forward_message';
  static const String callsHistory = '/calls_history';
  static const String chats = '/chats';
  static const String settings = '/settings';
  static const String chatDetails = 'details/:id';
  static const String call = '/call';
  static const String chatAttachSheet = '/chat_attach_sheet';
  static const String profileAvatarSheet = '/profile_avatar_sheet';
  static const String fullScreenMedia = '/full_screen_media';
  static const String photoEditor = '/photo_editor';
}
