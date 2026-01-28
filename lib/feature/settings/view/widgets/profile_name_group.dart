import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';

class ProfileNamesGroup extends StatefulWidget {
  const ProfileNamesGroup({super.key});

  @override
  State<ProfileNamesGroup> createState() => _ProfileNamesGroupState();
}

class _ProfileNamesGroupState extends State<ProfileNamesGroup> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final profileState = context.read<ProfileBloc>().state;
    if (profileState.user != null) {
      _firstNameController.text = profileState.editingFirstName ?? profileState.user!.firstName ?? '';
      _lastNameController.text = profileState.editingLastName ?? profileState.user!.lastName ?? '';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hintStyle = context.text.bodyLarge?.copyWith(
      color: context.appColors.hintText,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: context.appColors.secondaryBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            TextField(
              controller: _firstNameController,
              style: context.text.bodyLarge,
              onChanged: (value) {
                context.read<ProfileBloc>().add(
                  ProfileUpdateFirstNameEvent(value),
                );
              },
              decoration: InputDecoration(
                hintText: context.s.firstName,
                hintStyle: hintStyle,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                border: InputBorder.none,
              ),
            ),
            Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: context.appColors.divider,
            ),
            TextField(
              controller: _lastNameController,
              style: context.text.bodyLarge,
              onChanged: (value) {
                context.read<ProfileBloc>().add(
                  ProfileUpdateLastNameEvent(value),
                );
              },
              decoration: InputDecoration(
                hintText: context.s.lastName,
                hintStyle: hintStyle,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}