import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/settings/domain/locale_bloc/locale_bloc.dart';
import 'package:lets_talk/feature/settings/domain/locale_bloc/locale_event.dart';
import 'package:lets_talk/feature/settings/domain/locale_bloc/locale_state.dart';
import 'package:lets_talk/feature/settings/view/widgets/language_select_tile.dart';

class LanguageSelectSheet extends StatelessWidget {
  const LanguageSelectSheet({super.key});

  String _languageLabel(BuildContext context, String code) {
    switch (code) {
      case 'en':
        return context.s.languageEnglish;
      case 'ru':
        return context.s.languageRussian;
      case 'kk':
        return context.s.languageKazakh;
      default:
        return code;
    }
  }

  void _select(BuildContext context, Locale locale) {
    context.read<LocaleBloc>().add(LocaleChanged(locale));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.messageLight : AppColors.messageDark;

    const locales = [Locale('en'), Locale('ru'), Locale('kk')];

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: context.pop,
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: Icon(
                        Icons.close_rounded,
                        size: 24,
                        color: titleColor,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      context.s.selectLanguage,
                      textAlign: TextAlign.center,
                      style: AppTypography.textLgMedium.copyWith(color: titleColor),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),
            BlocBuilder<LocaleBloc, LocaleState>(
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < locales.length; i++) ...[
                        if (i > 0) const SizedBox(height: 8),
                        LanguageSelectTile(
                          title: _languageLabel(context, locales[i].languageCode),
                          isSelected:
                              state.locale.languageCode == locales[i].languageCode,
                          onTap: () => _select(context, locales[i]),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
