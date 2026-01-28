import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/domain/chats_bloc/chats_bloc.dart';
import 'package:lets_talk/feature/chats/view/chats_page.dart';

class ChatsPageScope extends StatelessWidget {
  const ChatsPageScope({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<ChatsBloc>()..add(ChatsLoad()),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: const ChatsPage(),
      ),
    );
  }
}
