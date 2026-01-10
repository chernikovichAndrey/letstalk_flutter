import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/auth/view/widgets/auth_button.dart';
import 'package:lets_talk/feature/auth/view/widgets/phone_input_field.dart';

class LoginCard extends StatelessWidget {
  const LoginCard({
    super.key,
    required this.phoneController,
    required this.countryCode,
    required this.onCountryCodeChanged,
    required this.onLoginPressed,
    this.initialCountryCode,
    this.onInit,
  });

  final TextEditingController phoneController;
  final CountryCode? countryCode;
  final ValueChanged<CountryCode> onCountryCodeChanged;
  final VoidCallback onLoginPressed;
  final String? initialCountryCode;
  final ValueChanged<CountryCode?>? onInit;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhoneInputField(
            controller: phoneController,
            countryCode: countryCode,
            onCountryCodeChanged: onCountryCodeChanged,
            initialCountryCode: initialCountryCode,
            onInit: onInit,
          ),
          const SizedBox(height: 24),
          AuthButton(
            text: context.s.signUpWithPhone,
            onPressed: onLoginPressed,
          ),
        ],
      ),
    );
  }
}
