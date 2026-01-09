import 'package:flutter/material.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/widget/c_alert_dialog.dart';
import 'package:lets_talk/feature/auth/view/login_page_scope.dart';

extension RoutesExt on Routes {
  Widget get widget {
    return switch (this) {
      Routes.login => LoginPageScope(),
      Routes.dialog => CAlertDialog(),
    };
  }
}
