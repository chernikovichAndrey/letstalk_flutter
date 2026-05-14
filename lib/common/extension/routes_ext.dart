import 'package:flutter/material.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/feature/calls_history/view/sheet/call_details_sheet.dart';
import 'package:lets_talk/feature/calls_history/view/sheet/call_contacts_sheet.dart';
import 'package:lets_talk/feature/chats/view/chat_details_page_scope.dart';
import 'package:lets_talk/feature/chats/view/create_chat_group_page.dart';
import 'package:lets_talk/feature/chats/view/select_contact_for_group_page.dart';
import 'package:lets_talk/feature/chats/view/sheet/add_contact_to_group_sheet.dart';
import 'package:lets_talk/feature/chats/view/sheet/chat_avatar_sheet.dart';
import 'package:lets_talk/feature/chats/view/sheet/chat_contact_sheet.dart';
import 'package:lets_talk/common/widget/c_alert_dialog.dart';
import 'package:lets_talk/feature/auth/view/auth_code_page.dart';
import 'package:lets_talk/feature/auth/view/auth_phone_page.dart';
import 'package:lets_talk/feature/auth/view/auth_profile_page.dart';
import 'package:lets_talk/feature/auth/view/login_page.dart';
import 'package:lets_talk/feature/auth/view/welcome_page.dart';
import 'package:lets_talk/feature/call/view/call_page.dart';
import 'package:lets_talk/feature/calls_history/view/calls_history_page_scope.dart';
import 'package:lets_talk/feature/chats/view/chats_page_scope.dart';
import 'package:lets_talk/feature/chats/view/sheet/chat_attachment_bottom_sheet.dart';
import 'package:lets_talk/feature/chats/view/sheet/chat_info_sheet.dart';
import 'package:lets_talk/feature/chats/view/sheet/forward_message_sheet.dart';
import 'package:lets_talk/feature/chats/view/sheet/full_screen_media_sheet.dart';
import 'package:lets_talk/feature/chats/view/sheet/media_viewer_sheet.dart';
import 'package:lets_talk/feature/chats/view/sheet/member_info_sheet.dart';
import 'package:lets_talk/feature/contacts/view/contacts_page_scope.dart';
import 'package:lets_talk/feature/contacts/view/create_contact_page_scope.dart';
import 'package:lets_talk/feature/settings/view/sheet/edit_profile_details_sheet.dart';
import 'package:lets_talk/feature/settings/view/photo_editor_page.dart';
import 'package:lets_talk/feature/settings/view/privacy_policy_page_scope.dart';
import 'package:lets_talk/feature/settings/view/settings_page.dart';
import 'package:lets_talk/feature/settings/view/sheet/language_select_sheet.dart';
import 'package:lets_talk/feature/settings/view/sheet/profile_avatar_bottom_sheet.dart';
import 'package:lets_talk/feature/settings/view/terms_of_service_page_scope.dart';
import 'package:lets_talk/feature/splash/view/splash_page.dart';

extension RoutesExt on Routes {
  Widget get widget {
    return switch (this) {
      Routes.splash => const SplashPage(),
      Routes.welcome => const WelcomePage(),
      Routes.authPhone => const AuthPhonePage(),
      Routes.authCode => const AuthCodePage(),
      Routes.authProfile => const AuthProfilePage(),
      Routes.login => const LoginPage(),
      Routes.contacts => const ContactsPageScope(),
      Routes.callsHistory => const CallsHistoryPageScope(),
      Routes.chats => const ChatsPageScope(),
      Routes.settings => const SettingsPage(),
      Routes.editProfileDetails => const EditProfileDetailsPage(),
      Routes.call => const CallPage(),
      Routes.chatDetails => const ChatDetailsPageScope(chatId: 0),
      Routes.dialog => const CAlertDialog(),
      Routes.createContact => const CreateContactPageScope(),
      Routes.callContacts => const CallContactsSheet(),
      Routes.chatContacts => const ChatContactsSheet(),
      Routes.forwardMessage => const ForwardMessageSheet(),
      Routes.callDetails => const CallDetailsSheet(),
      Routes.chatAttachSheet => const ChatAttachmentBottomSheet(),
      Routes.profileAvatarSheet => const ProfileAvatarBottomSheet(),
      Routes.chatAvatarSheet => const ChatAvatarBottomSheet(),
      Routes.fullScreenMedia => const FullScreenMediaSheet(),
      Routes.mediaViewer => const MediaViewerSheet(),
      Routes.photoEditor => const PhotoEditorPage(),
      Routes.selectContactsFroGroup => const SelectContactsForGroupPage(),
      Routes.createChatGroup => const CreateChatGroupPage(),
      Routes.addContactToGroupSheet => const AddContactToGroupSheet(),
      Routes.chatInfoSheet => const ChatInfoSheet(),
      Routes.memberInfoSheet => const MemberInfoSheet(),
      Routes.languageSelectSheet => const LanguageSelectSheet(),
      Routes.privacyPolicy => const PrivacyPolicyPageScope(),
      Routes.termsOfService => const TermsOfServicePageScope(),
    };
  }
}
