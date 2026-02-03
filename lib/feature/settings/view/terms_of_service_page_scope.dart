import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/feature/settings/domain/locale_bloc/locale_bloc.dart';
import 'package:lets_talk/feature/settings/domain/locale_bloc/locale_state.dart';
import 'package:lets_talk/feature/settings/view/html_document_page.dart';

class TermsOfServicePageScope extends StatelessWidget {
  const TermsOfServicePageScope({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleBloc, LocaleState>(
      builder: (context, state) {
        return HtmlDocumentPage(
          locale: state.locale.languageCode,
          documentType: LegalDocumentType.termsOfService,
        );
      },
    );
  }
}
