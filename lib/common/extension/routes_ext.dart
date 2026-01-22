import 'package:flutter/material.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/sheet/call_contacts_sheet.dart';
import 'package:lets_talk/common/widget/c_alert_dialog.dart';
import 'package:lets_talk/feature/auth/view/login_page.dart';
import 'package:lets_talk/feature/call/view/call_page.dart';
import 'package:lets_talk/feature/calls_history/view/calls_history_page_scope.dart';
import 'package:lets_talk/feature/chats/view/chats_page_scope.dart';
import 'package:lets_talk/feature/contacts/view/contacts_page_scope.dart';
import 'package:lets_talk/feature/contacts/view/create_contact_page_scope.dart';
import 'package:lets_talk/feature/settings/view/settings_page.dart';
import 'package:lets_talk/feature/splash/view/splash_page.dart';

extension RoutesExt on Routes {
  Widget get widget {
    return switch (this) {
      Routes.splash => const SplashPage(),
      Routes.login => const LoginPage(),
      Routes.contacts => const ContactsPageScope(),
      Routes.callsHistory => const CallsHistoryPageScope(),
      Routes.chats => const ChatsPageScope(),
      Routes.settings => const SettingsPage(),
      Routes.calls => const CallPage(),
      Routes.chatDetails => const SizedBox(),
      Routes.dialog => const CAlertDialog(),
      Routes.createContact => const CreateContactPageScope(),
      Routes.callContacts => const CallContactsSheet(),
    };
  }
}
