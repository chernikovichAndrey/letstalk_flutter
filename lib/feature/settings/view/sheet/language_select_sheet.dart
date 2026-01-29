import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_bottom_sheet.dart';
import 'package:lets_talk/feature/settings/domain/locale_bloc/locale_bloc.dart';
import 'package:lets_talk/feature/settings/domain/locale_bloc/locale_event.dart';
import 'package:lets_talk/feature/settings/domain/locale_bloc/locale_state.dart';

class LanguageSelectSheet extends StatelessWidget {
  const LanguageSelectSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return CBottomSheet(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            context.s.selectLanguage,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: context.color.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: BlocBuilder<LocaleBloc, LocaleState>(
            builder: (context, state) {
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _LanguageTile(
                    title: context.s.languageEnglish,
                    locale: const Locale('en'),
                    isSelected: state.locale.languageCode == 'en',
                    onTap: () {
                      context.read<LocaleBloc>().add(LocaleChanged(const Locale('en')));
                      context.pop();
                    },
                  ),
                  const SizedBox(height: 12),
                  _LanguageTile(
                    title: context.s.languageRussian,
                    locale: const Locale('ru'),
                    isSelected: state.locale.languageCode == 'ru',
                    onTap: () {
                      context.read<LocaleBloc>().add(LocaleChanged(const Locale('ru')));
                      context.pop();
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String title;
  final Locale locale;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.title,
    required this.locale,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: context.appColors.secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: context.appColors.telegramBlue, width: 2)
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: context.color.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: context.appColors.telegramBlue,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
