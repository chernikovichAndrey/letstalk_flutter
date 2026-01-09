import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class PhoneInputField extends StatelessWidget {
  const PhoneInputField({
    super.key,
    required this.controller,
    required this.countryCode,
    required this.onCountryCodeChanged,
  });

  final TextEditingController controller;
  final CountryCode? countryCode;
  final ValueChanged<CountryCode> onCountryCodeChanged;

  @override
  Widget build(BuildContext context) {
    const countryPicker = FlCountryCodePicker();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              final code = await countryPicker.showPicker(
                context: context,
              );
              if (code != null) {
                onCountryCodeChanged(code);
              }
            },
            child: Row(
              children: [
                if (countryCode != null)
                  countryCode!.flagImage(width: 32)
                else
                  const Icon(Icons.public, color: Colors.grey),
                const SizedBox(width: 8),
                const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (countryCode != null) ...[
            Text(
              countryCode!.dialCode,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (countryCode != null) return newValue;
                  if (newValue.text.isEmpty) return newValue;

                  if (!newValue.text.startsWith('+')) {
                    return oldValue;
                  }
                  return newValue;
                }),
              ],
              decoration: InputDecoration(
                hintText: context.s.enterPhoneNumber,
                border: InputBorder.none,
                hintStyle: const TextStyle(color: Colors.grey, letterSpacing: 0, fontSize: 14,),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
