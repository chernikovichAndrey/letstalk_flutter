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
    final appColors = context.appColors;
    final textTheme = context.text;

    return Container(
      decoration: BoxDecoration(
        color: appColors.inputFill,
        border: Border.all(color: appColors.divider),
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
            textStyle: textTheme.bodyLarge?.copyWith(
              color: Colors.black,
            ),
            dialogTextStyle: textTheme.bodyLarge,
            searchStyle: textTheme.bodyLarge,
            barrierColor: Colors.black.withValues(alpha: 0.5),
            dialogBackgroundColor: context.theme.scaffoldBackgroundColor,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              style: textTheme.bodyLarge?.copyWith(
                color: Colors.black,
              ),
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
                hintStyle: textTheme.bodyMedium?.copyWith(
                  color: Colors.black.withValues(alpha: 0.5),
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
