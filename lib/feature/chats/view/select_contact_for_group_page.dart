import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/view/widgets/select_contact_for_group/contacts_search_field.dart';
import 'package:lets_talk/feature/chats/view/widgets/select_contact_for_group/select_contact_for_group_app_bar.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';
import 'package:lets_talk/feature/contacts/view/widgets/contacts_skeleton.dart';
import 'package:lets_talk/feature/contacts/view/widgets/contacts_slivers.dart';

class SelectContactsForGroupPage extends StatefulWidget {
  const SelectContactsForGroupPage({super.key});

  @override
  State<SelectContactsForGroupPage> createState() =>
      _SelectContactsForGroupPageState();
}

class _SelectContactsForGroupPageState
    extends State<SelectContactsForGroupPage> {
  @override
  void deactivate() {
    getIt<ContactsBloc>().add(ContactsToggleSelectionMode());
    super.deactivate();
  }

  void _onPressNext() {
    final state = getIt<ContactsBloc>().state;
    if (state is! ContactsLoaded) return;
    if (state.selectedContactIds.isEmpty) return;
    context.push(Routes.createChatGroup);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<ContactsBloc>()..add(ContactsToggleSelectionMode()),
      child: Scaffold(
        backgroundColor: context.appColors.backgroundColor,
        appBar: SelectContactsForGroupAppBar(onPressNext: _onPressNext),
        body: BlocBuilder<ContactsBloc, ContactsState>(
          builder: (context, state) {
            if (state is ContactsLoading ||
                state is ContactsActionInProgress) {
              return const ContactsSceleton();
            }
            return CustomScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                if (state is ContactsLoaded)
                  SliverToBoxAdapter(
                    child: ContactsSearchField(state: state),
                  ),
                ContactsSlivers(
                  state: state,
                  isRegisteredOnly: true,
                  showSearch: false,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
