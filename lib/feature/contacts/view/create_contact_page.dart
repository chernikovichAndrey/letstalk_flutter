import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/toasts.dart';
import 'package:lets_talk/feature/contacts/data/model/contact_model.dart';
import 'package:lets_talk/feature/contacts/domain/add_contact_bloc/add_contact_bloc.dart';
import 'package:lets_talk/feature/contacts/view/widgets/create_contact_app_bar.dart';
import 'package:lets_talk/feature/contacts/view/widgets/create_contact_pone_input.dart';
import 'package:lets_talk/feature/contacts/view/widgets/create_contact_input_group.dart';

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
      showWarningToast(context.s.pleaseFillInFirstNameAndPhone);
      return;
    }

    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    final fullPhone = '$dialCode$cleanPhone';
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

  void _onInit(code) {
    if (_countryCode == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _countryCode = code;
          });
        }
      });
    }
  }

  void _onChangeCountryCode(code) {
    setState(() {
      _countryCode = code;
      _phoneController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddContactBloc, AddContactState>(
      listener: (context, state) {
        if (state is AddContactSuccess) {
          context.pop(context);
        }
      },
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Scaffold(
          backgroundColor: context.appColors.surfaceSecondary,
          appBar: CreateContactAppBar(onSave: _onSave),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CreatePhoneInputGroup(
                  firstNameController: _firstNameController,
                  lastNameController: _lastNameController,
                ),
                const SizedBox(height: 24),
                CreateContactPhoneInput(
                  countryCode: _countryCode,
                  phoneController: _phoneController,
                  onInit: _onInit,
                  onChangeCountry: _onChangeCountryCode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
