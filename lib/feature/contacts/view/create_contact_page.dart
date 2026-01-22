import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/glass_button.dart';
import 'package:lets_talk/feature/contacts/data/model/contact_model.dart';
import 'package:lets_talk/feature/contacts/domain/add_contact_bloc/add_contact_bloc.dart';

class CreateContactPage extends StatefulWidget {
  const CreateContactPage({super.key});

  @override
  State<CreateContactPage> createState() => _CreateContactPageState();
}

class _CreateContactPageState extends State<CreateContactPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  CountryCode? _countryCode;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onSave() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();
    final dialCode = _countryCode?.dialCode ?? '';

    if (firstName.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in first name and phone')),
      );
      return;
    }

    final fullPhone = '$dialCode$phone';
    final contact = Contact(
      phone: fullPhone,
      firstName: firstName,
      lastName: lastName,
      fullName: '$firstName $lastName'.trim(),
      email: '',
      address: '',
      imageUrl: '',
    );

    context.read<AddContactBloc>().add(AddContactSubmitted(contact));
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    final backgroundColor = appColors.surfaceSecondary;
    final cardColor = appColors.secondaryBackground;
    final dividerColor = appColors.divider;
    final hintStyle = context.text.bodyLarge?.copyWith(
      color: appColors.hintText,
    );

    return BlocListener<AddContactBloc, AddContactState>(
      listener: (context, state) {
        if (state is AddContactSuccess) {
          Navigator.pop(context, true);
        } else if (state is AddContactError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: backgroundColor,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GlassButton(
                icon: Icons.close,
                onTap: () => Navigator.pop(context),
              ),
            ),
            title: Text(
              context.s.newContact,
              style: context.text.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: appColors.glassForeground,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: BlocBuilder<AddContactBloc, AddContactState>(
                  builder: (context, state) {
                    if (state is AddContactInProgress) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }
                    return GlassButton(
                      icon: Icons.check,
                      onTap: _onSave,
                    );
                  },
                ),
              ),
            ],
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Name Fields Group
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _firstNameController,
                        style: context.text.bodyLarge,
                        decoration: InputDecoration(
                          hintText: context.s.firstName,
                          hintStyle: hintStyle,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          border: InputBorder.none,
                        ),
                      ),
                      Divider(height: 1, indent: 16, endIndent: 16, color: dividerColor),
                      TextField(
                        controller: _lastNameController,
                        style: context.text.bodyLarge,
                        decoration: InputDecoration(
                          hintText: context.s.lastName,
                          hintStyle: hintStyle,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          border: InputBorder.none,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Phone Fields Group
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      // Country Selector Row
                      CountryCodePicker(
                        onChanged: (code) {
                          setState(() {
                            _countryCode = code;
                          });
                        },
                        onInit: (code) {
                          if (_countryCode == null && code != null) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() {
                                  _countryCode = code;
                                });
                              }
                            });
                          }
                        },
                        initialSelection: View.of(context).platformDispatcher.locale.countryCode,
                        favorite: const ['RU', 'KZ'],
                        showCountryOnly: true,
                        showOnlyCountryWhenClosed: true,
                        alignLeft: true,
                        padding: EdgeInsets.zero,
                        builder: (CountryCode? code) {
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            leading: code != null ? Image.asset(
                              code.flagUri!,
                              package: 'country_code_picker',
                              width: 24,
                            ) : null,
                            title: Text(
                              code?.name ?? '',
                              style: context.text.bodyLarge,
                            ),
                            trailing: const Icon(Icons.chevron_right, size: 20),
                          );
                        },
                        textStyle: context.text.bodyLarge,
                        dialogTextStyle: context.text.bodyLarge,
                        searchStyle: context.text.bodyLarge,
                        barrierColor: Colors.black.withValues(alpha: 0.5),
                        dialogBackgroundColor: context.theme.scaffoldBackgroundColor,
                      ),
                      Divider(height: 1, indent: 16, endIndent: 16, color: dividerColor),
                      // Phone Input Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Row(
                          children: [
                            if (_countryCode != null)
                              Text(
                                _countryCode!.dialCode ?? '',
                                style: context.text.bodyLarge,
                              ),
                            const SizedBox(width: 12),
                            Container(
                              width: 1,
                              height: 24,
                              color: appColors.divider,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: context.text.bodyLarge,
                                decoration: InputDecoration(
                                  hintText: '00 000 0000',
                                  hintStyle: hintStyle,
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
