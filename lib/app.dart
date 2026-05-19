import 'dart:ui';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lets_talk/app/config/app_theme.dart';
import 'package:lets_talk/app/router/app_router.dart';
import 'package:lets_talk/common/service/webrtc_service.dart';
import 'package:lets_talk/common/service/websocket_service.dart';
import 'package:lets_talk/common/service/ringtone_service.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/auth/domain/auth_bloc/auth_bloc.dart';
import 'package:lets_talk/feature/call/domain/bloc/call_bloc.dart';
import 'package:lets_talk/feature/shell/connectivity/domain/bloc/connectivity_bloc.dart';
import 'package:lets_talk/feature/shell/domain/navigation_bloc/navigation_bloc.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';
import 'package:lets_talk/feature/settings/domain/locale_bloc/locale_bloc.dart';
import 'package:lets_talk/feature/settings/domain/locale_bloc/locale_event.dart';
import 'package:lets_talk/feature/settings/domain/locale_bloc/locale_state.dart';
import 'package:lets_talk/feature/settings/domain/theme_bloc/theme_bloc.dart';
import 'package:lets_talk/feature/settings/domain/theme_bloc/theme_event.dart';
import 'package:lets_talk/feature/settings/domain/theme_bloc/theme_state.dart';

import 'common/l10n/generated/l10n.dart';
import 'common/mixin/handle_push_notification.dart';
import 'feature/chats/domain/chats_bloc/chats_bloc.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with HandlePushNotification {

  @override
  void initState() {
    super.initState();
    router = AppRouter();
    getIt<WebSocketService>().connect();
    setupPushNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: getIt()..add(AuthCheckStatus())),
        BlocProvider<ProfileBloc>.value(value: getIt()),
        BlocProvider<CallBloc>.value(value: getIt()),
        BlocProvider<ConnectivityBloc>.value(value: getIt()),
        BlocProvider<NavigationBloc>.value(value: getIt()),
        BlocProvider<LocaleBloc>.value(value: getIt()..add(LoadSavedLocale())),
        BlocProvider<ThemeBloc>.value(value: getIt()..add(LoadSavedTheme())),
        BlocProvider<ChatsBloc>.value(value: getIt()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LocaleBloc, LocaleState>(
            builder: (context, localeState) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                routerConfig: router.config,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: themeState.mode,
                localizationsDelegates: [
                  S.delegate,
                  CountryLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: S.delegate.supportedLocales,
                locale: localeState.locale,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.noScaling,
                  ),
                  child: child!,
                ),
                scrollBehavior: const MaterialScrollBehavior().copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.stylus,
                    PointerDeviceKind.trackpad,
                    PointerDeviceKind.mouse,
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    notificationSubscription?.cancel();
    localNotificationSubscription?.cancel();
    router.dispose();
    getIt<WebSocketService>().disconnect();
    getIt<WebRTCService>().dispose();
    getIt<RingtoneService>().dispose();
    super.dispose();
  }
}
