import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/feature/calls_history/data/repository/calls_repository_impl.dart';
import 'package:lets_talk/feature/calls_history/domain/calls_hisotry_bloc/calls_history_bloc.dart';
import 'package:lets_talk/feature/calls_history/view/calls_history_page.dart';

class CallsHistoryPageScope extends StatelessWidget {
  const CallsHistoryPageScope({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CallsHistoryBloc(CallsRepositoryImpl())..add(LoadHistoryCalls()),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: const CallsHistoryPage(),
      ),
    );
  }
}