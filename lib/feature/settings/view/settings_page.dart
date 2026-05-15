import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/arg/chat_details_args.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/extension/list_ext.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/domain/chats_bloc/chats_bloc.dart';
import 'package:lets_talk/feature/settings/domain/locale_bloc/locale_bloc.dart';
import 'package:lets_talk/feature/settings/domain/locale_bloc/locale_state.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';
import 'package:lets_talk/feature/settings/domain/theme_bloc/theme_bloc.dart';
import 'package:lets_talk/feature/settings/domain/theme_bloc/theme_state.dart';
import 'package:lets_talk/feature/settings/view/widgets/profile_widget.dart';
import 'package:lets_talk/feature/settings/view/widgets/settings_app_bar.dart';
import 'package:lets_talk/feature/settings/view/widgets/settings_footer.dart';
import 'package:lets_talk/feature/settings/view/widgets/settings_menu_card.dart';
import 'package:lets_talk/feature/settings/view/widgets/settings_menu_item.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  String _localeLabel(BuildContext context, Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return context.s.languageEnglish;
      case 'kk':
        return context.s.languageKazakh;
      default:
        return context.s.languageRussian;
    }
  }

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

  void _openFavorites(BuildContext context) {
    final state = getIt<ChatsBloc>().state;
    if (state is! ChatsLoaded) return;
    final favoriteChat = state.chats.firstWhereOrNull(
      (chat) => chat.type == 'favorites',
    );
    if (favoriteChat != null) {
      context.push(
        '${Routes.chats.path}/${Routes.chatDetails.path}',
        extra: ChatDetailsArgs(chatId: favoriteChat.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: context.appColors.backgroundColor,
      body: Stack(
        children: [
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state.status == ProfileStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status != ProfileStatus.loaded &&
                  state.status != ProfileStatus.avatarUploadLoading) {
                return const SizedBox.shrink();
              }

              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.only(
                      top: context.padding.top + 56,
                      bottom: 160,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: [
                          ProfileWidget(
                            onAvatarTap: () =>
                                context.push(Routes.profileAvatarSheet.path),
                          ),
                          const SizedBox(height: 36),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: BlocBuilder<LocaleBloc, LocaleState>(
                              builder: (context, localeState) {
                                return BlocBuilder<ThemeBloc, ThemeState>(
                                  builder: (context, themeState) {
                                    return SettingsMenuCard(
                                      children: [
                                        SettingsMenuItem(
                                          icon: Icons.bookmark_border_rounded,
                                          label: context.s.favorites,
                                          onTap: () => _openFavorites(context),
                                        ),
                                        SettingsMenuItem(
                                          icon: Icons.language_outlined,
                                          label: context.s.language,
                                          value: _localeLabel(
                                            context,
                                            localeState.locale,
                                          ),
                                          onTap: () => context.push(
                                            Routes.languageSelectSheet.path,
                                          ),
                                        ),
                                        SettingsMenuItem(
                                          icon: Icons.contrast_rounded,
                                          label: context.s.theme,
                                          value: _themeLabel(
                                            context,
                                            themeState.mode,
                                          ),
                                          onTap: () => context.push(
                                            Routes.themeSelectSheet.path,
                                          ),
                                          showDivider: false,
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SettingsAppBar(),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: SettingsFooter(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
