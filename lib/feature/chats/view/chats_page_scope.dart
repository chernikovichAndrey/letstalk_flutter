import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/feature/chats/data/repository/chats_repository_impl.dart';
import 'package:lets_talk/feature/chats/domain/chats_bloc/chats_bloc.dart';
import 'package:lets_talk/feature/chats/view/chats_page.dart';

class ChatsPageScope extends StatelessWidget {
  const ChatsPageScope({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatsBloc(ChatsRepositoryImpl())..add(ChatsLoad()),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: const ChatsPage(),
      ),
    );
  }
}