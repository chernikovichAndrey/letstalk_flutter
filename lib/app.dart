import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lets_talk/app/config/app_theme.dart';
import 'package:lets_talk/app/environment/environment.dart';
import 'package:lets_talk/app/router/app_router.dart';
import 'package:lets_talk/common/service/webrtc_service.dart';
import 'package:lets_talk/common/service/websocket_service.dart';
import 'package:lets_talk/common/service/ringtone_service.dart';
import 'package:lets_talk/feature/auth/data/repository/auth_repository_impl.dart';
import 'package:lets_talk/feature/auth/domain/auth_bloc/auth_bloc.dart';
import 'package:lets_talk/feature/call/data/repository/call_repository_impl.dart';
import 'package:lets_talk/feature/call/domain/bloc/call_bloc.dart';
import 'package:lets_talk/feature/settings/data/repository/profile_repository_impl.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';

import 'common/l10n/generated/l10n.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AppRouter router;
  final _webRTCService = WebRTCService();
  final _ringtoneService = RingtoneService();
  final _callRepository = CallRepositoryImpl();

  @override
  void initState() {
    super.initState();
    router = AppRouter();
    final wsUrl = Env.wsUrl;
    WebSocketService().connect(wsUrl);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
          AuthBloc(AuthRepositoryImpl())..add(AuthCheckStatus()),
        ),
        BlocProvider(
          create: (context) => ProfileBloc(ProfileRepositoryImpl()),
        ),
        BlocProvider(
          create: (context) => CallBloc(
            callRepository: _callRepository,
          ),
        ),
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
    WebSocketService().disconnect();
    _webRTCService.dispose();
    _ringtoneService.dispose();
    super.dispose();
  }
}
