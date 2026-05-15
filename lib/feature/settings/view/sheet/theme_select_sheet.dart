import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/settings/domain/theme_bloc/theme_bloc.dart';
import 'package:lets_talk/feature/settings/domain/theme_bloc/theme_event.dart';
import 'package:lets_talk/feature/settings/domain/theme_bloc/theme_state.dart';
import 'package:lets_talk/feature/settings/view/widgets/theme_select_tile.dart';

class ThemeSelectSheet extends StatelessWidget {
  const ThemeSelectSheet({super.key});

  String _themeLabel(BuildContext context, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return context.s.themeLight;
      case ThemeMode.dark:
        return context.s.themeDark;
      case ThemeMode.system:
        return context.s.themeSystem;
    }
  }

  void _select(BuildContext context, ThemeMode mode) {
    context.read<ThemeBloc>().add(ThemeChanged(mode));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.messageLight : AppColors.messageDark;

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
                      context.s.selectTheme,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),
            BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ThemeSelectTile(
                        title: _themeLabel(context, ThemeMode.system),
                        isSelected: state.mode == ThemeMode.system,
                        onTap: () => _select(context, ThemeMode.system),
                      ),
                      const SizedBox(height: 8),
                      ThemeSelectTile(
                        title: _themeLabel(context, ThemeMode.light),
                        isSelected: state.mode == ThemeMode.light,
                        onTap: () => _select(context, ThemeMode.light),
                      ),
                      const SizedBox(height: 8),
                      ThemeSelectTile(
                        title: _themeLabel(context, ThemeMode.dark),
                        isSelected: state.mode == ThemeMode.dark,
                        onTap: () => _select(context, ThemeMode.dark),
                      ),
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
