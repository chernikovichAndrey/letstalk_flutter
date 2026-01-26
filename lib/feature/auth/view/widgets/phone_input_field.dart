import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:phone_numbers_parser/metadata.dart' show metadataExamplesByIsoCode;
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class PhoneInputField extends StatefulWidget {
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
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  MaskTextInputFormatter? _phoneMaskFormatter;

  @override
  void initState() {
    super.initState();
    _updatePhoneMask();
  }

  @override
  void didUpdateWidget(PhoneInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.countryCode?.code != widget.countryCode?.code) {
      widget.controller.clear();
      _updatePhoneMask();
    }
  }

  void _updatePhoneMask() {
    final countryCode = widget.countryCode?.code ?? widget.initialCountryCode;
    if (countryCode == null) {
      setState(() {
        _phoneMaskFormatter = null;
      });
      return;
    }

    try {
      final isoCode = IsoCode.fromJson(countryCode);
      final exampleMetadata = metadataExamplesByIsoCode[isoCode];

      final mobileExample = exampleMetadata?.mobile;
      final fixedLineExample = exampleMetadata?.fixedLine;

      String? exampleNumber = mobileExample ?? fixedLineExample;

      if (exampleNumber != null) {
        final mask = _createMaskFromExample(exampleNumber, isoCode);
        setState(() {
          _phoneMaskFormatter = MaskTextInputFormatter(
            mask: mask,
            filter: {"#": RegExp(r'\d')},
          );
        });
      }
    } catch (e) {
      setState(() {
        _phoneMaskFormatter = null;
      });
    }
  }

  String _createMaskFromExample(String exampleNumber, IsoCode isoCode) {
    try {
      final phoneNumber = PhoneNumber.parse(
        exampleNumber,
        callerCountry: isoCode,
      );
      final formatted = phoneNumber.formatNsn();

      return formatted.replaceAllMapped(
        RegExp(r'\d'),
        (match) => '#',
      );
    } catch (e) {
      return exampleNumber.replaceAllMapped(
        RegExp(r'\d'),
        (match) => '#',
      );
    }
  }

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
            onChanged: (code) {
              widget.onCountryCodeChanged(code);
            },
            onInit: widget.onInit,
            initialSelection: widget.countryCode?.code ?? widget.initialCountryCode,
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
              controller: widget.controller,
              keyboardType: TextInputType.phone,
              style: textTheme.bodyLarge?.copyWith(
                color: Colors.black,
              ),
              inputFormatters: _phoneMaskFormatter != null
                  ? [_phoneMaskFormatter!]
                  : [],
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
