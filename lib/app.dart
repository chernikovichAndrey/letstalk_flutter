import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lets_talk/app/config/app_theme.dart';
import 'package:lets_talk/app/environment/environment.dart';
import 'package:lets_talk/app/router/app_router.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/service/websocket_service.dart';
import 'package:lets_talk/feature/auth/data/repository/auth_repository_impl.dart';
import 'package:lets_talk/feature/auth/domain/auth_bloc/auth_bloc.dart';
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
          create: (context) => AuthBloc(AuthRepositoryImpl())..add(AuthCheckStatus()),
        ),
        BlocProvider(
          create: (context) => ProfileBloc(ProfileRepositoryImpl()),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            if (state.token != null) {
              WebSocketService().authenticate(state.token!);
            }
            context.read<ProfileBloc>().add(ProfileLoadEvent());
            router.config.go(Routes.contacts.path);
          } else if (state is AuthUnauthenticated) {
            WebSocketService().disconnect();
            router.config.go(Routes.login.path);
          }
        },
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
      ),
    );
  }

  @override
  void dispose() {
    router.dispose();
    super.dispose();
  }
}
