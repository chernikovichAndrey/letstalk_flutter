import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class PhoneInputField extends StatelessWidget {
  const PhoneInputField({
    super.key,
    required this.controller,
    required this.countryCode,
    required this.onCountryCodeChanged,
    this.initialCountryCode,
    this.onInit,
  });

  final TextEditingController controller;
  final CountryCode? countryCode;
  final ValueChanged<CountryCode> onCountryCodeChanged;
  final String? initialCountryCode;
  final ValueChanged<CountryCode?>? onInit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CountryCodePicker(
            onChanged: onCountryCodeChanged,
            onInit: onInit,
            initialSelection: countryCode?.code ?? initialCountryCode,
            favorite: const ['RU', 'KZ'],
            padding: EdgeInsets.zero,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (countryCode != null) return newValue;
                  if (newValue.text.isEmpty) return newValue;
                  return newValue;
                }),
              ],
              decoration: InputDecoration(
                hintText: context.s.enterPhoneNumber,
                border: InputBorder.none,
                hintStyle: const TextStyle(
                  color: Colors.grey,
                  letterSpacing: 0,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
