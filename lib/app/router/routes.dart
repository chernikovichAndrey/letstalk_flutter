import 'package:lets_talk/app/router/route_type.dart';

enum Routes {
  splash(path: _Paths.splash, type: RouteType.page),
  welcome(path: _Paths.welcome, type: RouteType.page),
  authPhone(path: _Paths.authPhone, type: RouteType.page),
  authCode(path: _Paths.authCode, type: RouteType.page),
  authProfile(path: _Paths.authProfile, type: RouteType.page),
  contacts(path: _Paths.contacts, type: RouteType.page),
  callsHistory(path: _Paths.callsHistory, type: RouteType.page),
  chats(path: _Paths.chats, type: RouteType.page),
  settings(path: _Paths.settings, type: RouteType.page),
  editProfileDetails(path: _Paths.editProfileDetails, type: RouteType.sheet),
  chatDetails(path: _Paths.chatDetails, type: RouteType.page),
  call(path: _Paths.call, type: RouteType.page),
  // dialogs
  dialog(path: _Paths.dialog, type: RouteType.dialog),
  // sheets
  createContact(path: _Paths.createContact, type: RouteType.sheet),
  callContacts(path: _Paths.callContacts, type: RouteType.sheet),
  chatContacts(path: _Paths.chatContacts, type: RouteType.sheet),
  callDetails(path: _Paths.callDetails, type: RouteType.sheet),
  forwardMessage(path: _Paths.forwardMessage, type: RouteType.bottomSheet),
  fullScreenMedia(path: _Paths.fullScreenMedia, type: RouteType.sheet),
  mediaViewer(path: _Paths.mediaViewer, type: RouteType.bottomSheet),
  chatAttachSheet(path: _Paths.chatAttachSheet, type: RouteType.bottomSheet),
  profileAvatarSheet(path: _Paths.profileAvatarSheet, type: RouteType.bottomSheet),
  chatAvatarSheet(path: _Paths.chatAvatarSheet, type: RouteType.bottomSheet),
  selectContactsFroGroup(path: _Paths.selectContactsFroGroup, type: RouteType.page),
  createChatGroup(path: _Paths.createChatGroup, type: RouteType.page),
  addContactToGroupSheet(path: _Paths.addContactToGroupSheet, type: RouteType.bottomSheet),
  chatInfoSheet(path: _Paths.chatInfoSheet, type: RouteType.bottomSheet),
  memberInfoSheet(path: _Paths.memberInfoSheet, type: RouteType.bottomSheet),
  languageSelectSheet(path: _Paths.languageSelectSheet, type: RouteType.bottomSheet),
  photoEditor(path: _Paths.photoEditor, type: RouteType.page),
  privacyPolicy(path: _Paths.privacyPolicy, type: RouteType.page),
  termsOfService(path: _Paths.termsOfService, type: RouteType.page);

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
  static const String welcome = '/welcome';
  static const String dialog = '/alert';
  static const String authPhone = '/auth_phone';
  static const String authCode = '/auth_code';
  static const String authProfile = '/auth_profile';
  static const String contacts = '/contacts';
  static const String createContact = '/create_contact';
  static const String callContacts = '/call_contacts';
  static const String chatContacts = '/chat_contacts';
  static const String callDetails = '/call_details/:id';
  static const String forwardMessage = '/forward_message';
  static const String callsHistory = '/calls_history';
  static const String chats = '/chats';
  static const String settings = '/settings';
  static const String editProfileDetails = '/edit_profile_details';
  static const String chatDetails = 'details/:id';
  static const String call = '/call';
  static const String chatAttachSheet = '/chat_attach_sheet';
  static const String profileAvatarSheet = '/profile_avatar_sheet';
  static const String chatAvatarSheet = '/chat_avatar_sheet';
  static const String fullScreenMedia = '/full_screen_media';
  static const String mediaViewer = '/media_viewer';
  static const String photoEditor = '/photo_editor';
  static const String selectContactsFroGroup = '/select_contacts_fro_group';
  static const String createChatGroup = '/create_chat_group';
  static const String addContactToGroupSheet = '/add_contact_to_group_sheet';
  static const String chatInfoSheet = '/call_info_sheet';
  static const String memberInfoSheet = '/member_info_sheet';
  static const String languageSelectSheet = '/language_select_sheet';
  static const String privacyPolicy = '/privacy_policy';
  static const String termsOfService = '/terms_of_service';
}
