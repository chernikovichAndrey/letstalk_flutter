import 'package:flutter/material.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/widget/c_alert_dialog.dart';
import 'package:lets_talk/feature/auth/view/login_page.dart';
import 'package:lets_talk/feature/calls/view/calls_page.dart';
import 'package:lets_talk/feature/chats/view/chats_page.dart';
import 'package:lets_talk/feature/contacts/view/contacts_page.dart';
import 'package:lets_talk/feature/settings/view/settings_page.dart';

extension RoutesExt on Routes {
  Widget get widget {
    return switch (this) {
      Routes.login => const LoginPage(),
      Routes.contacts => const ContactsPage(),
      Routes.calls => const CallsPage(),
      Routes.chats => const ChatsPage(),
      Routes.settings => const SettingsPage(),
      Routes.dialog => const CAlertDialog(),
    };
  }
}
