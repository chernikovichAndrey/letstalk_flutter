import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/feature/auth/data/repository/auth_repository_impl.dart';
import 'package:lets_talk/feature/auth/domain/auth_bloc/auth_bloc.dart';

import 'login_page.dart';

class LoginPageScope extends StatelessWidget {
  const LoginPageScope({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>.value(
      value: AuthBloc(AuthRepositoryImpl()),
      child: LoginPage(),
    );
  }
}