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
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';

import 'common/l10n/generated/l10n.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AppRouter router;

  @override
  void initState() {
    super.initState();
    router = AppRouter();
    getIt<WebSocketService>().connect();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: getIt()),
        BlocProvider<ProfileBloc>.value(value: getIt()),
        BlocProvider<CallBloc>.value(value: getIt()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router.config,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        locale: S.delegate.supportedLocales.first,
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.stylus,
            PointerDeviceKind.trackpad,
            PointerDeviceKind.mouse,
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    router.dispose();
    getIt<WebSocketService>().disconnect();
    getIt<WebRTCService>().dispose();
    getIt<RingtoneService>().dispose();
    super.dispose();
  }
}
