import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/feature/calls/data/repository/calls_repository_impl.dart';
import 'package:lets_talk/feature/calls/domain/calls_bloc/calls_bloc.dart';
import 'package:lets_talk/feature/calls/view/calls_page.dart';

class CallsPageScope extends StatelessWidget {
  const CallsPageScope({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CallsBloc(CallsRepositoryImpl())..add(LoadCalls()),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: const CallsPage(),
      ),
    );
  }
}