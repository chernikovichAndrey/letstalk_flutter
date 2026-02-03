import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/feature/settings/domain/locale_bloc/locale_bloc.dart';
import 'package:lets_talk/feature/settings/domain/locale_bloc/locale_state.dart';
import 'package:lets_talk/feature/settings/view/privacy_policy_page.dart';

class PrivacyPolicyPageScope extends StatelessWidget {
  const PrivacyPolicyPageScope({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleBloc, LocaleState>(
      builder: (context, state) {
        return PrivacyPolicyPage(locale: state.locale.languageCode);
      },
    );
  }
}
