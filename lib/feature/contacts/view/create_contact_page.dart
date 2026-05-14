import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_name_input_card.dart';
import 'package:lets_talk/common/widget/c_phone_input.dart';
import 'package:lets_talk/common/widget/toasts.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/contacts/data/model/contact_model.dart';
import 'package:lets_talk/feature/contacts/domain/add_contact_bloc/add_contact_bloc.dart';
import 'package:lets_talk/feature/contacts/view/widgets/create_contact_app_bar.dart';

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

  Future<void> _onSave() async {
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

    final bloc = getIt<AddContactBloc>();
    bloc.add(AddContactSubmitted(contact));

    final state = await bloc.stream.firstWhere(
      (s) => s is AddContactSuccess || s is AddContactError,
    );

    if (!mounted) return;
    if (state is AddContactSuccess) {
      context.pop();
    }
  }

  void _onCountryInit(CountryCode? code) {
    if (_countryCode != null || code == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _countryCode = code);
    });
  }

  void _onCountryChanged(CountryCode code) {
    setState(() {
      _countryCode = code;
      _phoneController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final initialCountry =
        View.of(context).platformDispatcher.locale.countryCode;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Scaffold(
        appBar: CreateContactAppBar(onSave: _onSave),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            children: [
              CNameInputCard(
                firstNameController: _firstNameController,
                lastNameController: _lastNameController,
              ),
              const SizedBox(height: 16),
              CPhoneInput(
                controller: _phoneController,
                countryCode: _countryCode,
                initialCountryCode: initialCountry,
                onInit: _onCountryInit,
                onCountryCodeChanged: _onCountryChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
