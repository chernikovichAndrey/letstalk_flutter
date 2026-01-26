import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:phone_numbers_parser/metadata.dart' show metadataExamplesByIsoCode;

class CreateContactPhoneInput extends StatefulWidget {
  final CountryCode? countryCode;
  final TextEditingController phoneController;
  final ValueChanged<CountryCode>? onChangeCountry;
  final ValueChanged<CountryCode?>? onInit;

  const CreateContactPhoneInput({super.key, this.countryCode, required this.phoneController, required this.onChangeCountry, required this.onInit});

  @override
  State<CreateContactPhoneInput> createState() => _CreateContactPhoneInputState();
}

class _CreateContactPhoneInputState extends State<CreateContactPhoneInput> {
  MaskTextInputFormatter? _phoneMaskFormatter;

  void _updatePhoneMask(CountryCode? countryCode) {
    print('1111 ${countryCode?.code}');
    if (countryCode?.code == null) {
      _phoneMaskFormatter = null;
      return;
    }

    try {
      final isoCode = IsoCode.fromJson(countryCode!.code!);
      final exampleMetadata = metadataExamplesByIsoCode[isoCode];

      final mobileExample = exampleMetadata?.mobile;
      final fixedLineExample = exampleMetadata?.fixedLine;

      String? exampleNumber = mobileExample ?? fixedLineExample;

      if (exampleNumber != null) {
        final mask = _createMaskFromExample(exampleNumber);
        _phoneMaskFormatter = MaskTextInputFormatter(
          mask: mask,
          filter: {"#": RegExp(r'\d')},
        );
      }
    } catch (e) {
      _phoneMaskFormatter = null;
    }
  }

  String _createMaskFromExample(String exampleNumber) {
    try {
      final phoneNumber = PhoneNumber.parse(
        exampleNumber,
        callerCountry: IsoCode.fromJson(widget.countryCode!.code!),
      );
      final formatted = phoneNumber.formatNsn();

      // Convert formatted number to mask pattern
      return formatted.replaceAllMapped(
        RegExp(r'\d'),
            (match) => '#',
      );
    } catch (e) {
      // Fallback mask
      return exampleNumber.replaceAllMapped(
        RegExp(r'\d'),
            (match) => '#',
      );
    }
  }

  String _getPhoneHint() {
    if (widget.countryCode?.code == null) return '00 000 0000';

    try {
      final isoCode = IsoCode.fromJson(widget.countryCode!.code!);
      final exampleMetadata = metadataExamplesByIsoCode[isoCode];

      final mobileExample = exampleMetadata?.mobile;
      final fixedLineExample = exampleMetadata?.fixedLine;

      if (mobileExample != null) {
        return _formatAsHint(mobileExample);
      } else if (fixedLineExample != null) {
        return _formatAsHint(fixedLineExample);
      }
    } catch (e) {
      // Fallback for unsupported countries
    }

    return '00 000 0000';
  }

  String _formatAsHint(String exampleNumber) {
    if (exampleNumber.isEmpty) return '00 000 0000';

    try {
      final phoneNumber = PhoneNumber.parse(
        exampleNumber,
        callerCountry: IsoCode.fromJson(widget.countryCode!.code!),
      );
      final formatted = phoneNumber.formatNsn();

      // Replace all digits with 0
      return formatted.replaceAllMapped(
        RegExp(r'\d'),
            (match) => '0',
      );
    } catch (e) {
      // If parsing fails, fallback to simple format
      return exampleNumber.replaceAllMapped(
        RegExp(r'\d'),
            (match) => '0',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Country Selector Row
          CountryCodePicker(
            onChanged: (code) {
              widget.onChangeCountry!(code);
              _updatePhoneMask(code);
            },
            onInit: (code) {
              widget.onInit!(code);
              _updatePhoneMask(code);
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
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: context.appColors.divider,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                if (widget.countryCode != null)
                  Text(
                    widget.countryCode!.dialCode ?? '',
                    style: context.text.bodyLarge,
                  ),
                const SizedBox(width: 12),
                Container(
                  width: 1,
                  height: 24,
                  color: context.appColors.divider,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: widget.phoneController,
                    keyboardType: TextInputType.phone,
                    style: context.text.bodyLarge,
                    inputFormatters: _phoneMaskFormatter != null
                        ? [_phoneMaskFormatter!]
                        : [],
                    decoration: InputDecoration(
                      hintText: _getPhoneHint(),
                      hintStyle: context.text.bodyLarge?.copyWith(
                        color: context.appColors.hintText,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}