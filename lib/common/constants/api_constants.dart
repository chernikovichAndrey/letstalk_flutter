class ApiConstants {
  static const String loginCode = '/login/code';
  static const String login = '/login';
  static const String profile = '/profile';
  static const String calls = '/calls';
  static const String contacts = '/profile/contacts';
  static const String addContact = '/profile/contacts/add';
  static const String chats = '/chats';
  static const String chatsSearch = '/chats/search';
  static const String messages = '/messages';
  static const String mediaUpload = '/media/upload';
  static const String profileAvatar = '/profile/avatar';
  static const String updateFcmToken = '/device/update-fcm-token';
  static const String updateVoipToken = '/device/update-voip-token';
  static const String turnCredentials = '/turn/credentials';
  static String callOffer(int callId) => '/calls/$callId/offer';
  static String chatAvatar(int chatId) => '/chats/$chatId/avatar';
  static String chatMute(int chatId) => '/chats/$chatId/mute';
}
