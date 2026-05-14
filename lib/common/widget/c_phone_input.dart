import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:phone_numbers_parser/metadata.dart'
    show metadataExamplesByIsoCode;
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

/// Phone number input from Figma design "Number input" (node 996:31965).
///
/// Renders a 56px pill with a country code button on the left and a
/// phone text field on the right. Adapts to light/dark theme.
class CPhoneInput extends StatefulWidget {
  const CPhoneInput({
    super.key,
    required this.controller,
    required this.countryCode,
    required this.onCountryCodeChanged,
    this.initialCountryCode,
    this.onInit,
    this.onChanged,
  });

  final TextEditingController controller;
  final CountryCode? countryCode;
  final ValueChanged<CountryCode> onCountryCodeChanged;
  final String? initialCountryCode;
  final ValueChanged<CountryCode?>? onInit;
  final ValueChanged<String>? onChanged;

  @override
  State<CPhoneInput> createState() => _CPhoneInputState();
}

class _CPhoneInputState extends State<CPhoneInput> {
  MaskTextInputFormatter? _phoneMaskFormatter;

  @override
  void initState() {
    super.initState();
    _updatePhoneMask();
  }

  @override
  void didUpdateWidget(CPhoneInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.countryCode?.code != widget.countryCode?.code) {
      widget.controller.clear();
      _updatePhoneMask();
    }
  }

  void _updatePhoneMask() {
    final countryCode = widget.countryCode?.code ?? widget.initialCountryCode;
    if (countryCode == null) {
      setState(() => _phoneMaskFormatter = null);
      return;
    }

    try {
      final isoCode = IsoCode.fromJson(countryCode);
      final exampleMetadata = metadataExamplesByIsoCode[isoCode];
      final exampleNumber =
          exampleMetadata?.mobile ?? exampleMetadata?.fixedLine;

      if (exampleNumber != null) {
        final mask = _createMaskFromExample(exampleNumber, isoCode);
        setState(() {
          _phoneMaskFormatter = MaskTextInputFormatter(
            mask: mask,
            filter: {'#': RegExp(r'\d')},
          );
        });
      }
    } catch (_) {
      setState(() => _phoneMaskFormatter = null);
    }
  }

  String _createMaskFromExample(String exampleNumber, IsoCode isoCode) {
    try {
      final phoneNumber = PhoneNumber.parse(
        exampleNumber,
        callerCountry: isoCode,
      );
      final formatted = phoneNumber.formatNsn();
      return formatted.replaceAllMapped(RegExp(r'\d'), (_) => '#');
    } catch (_) {
      return exampleNumber.replaceAllMapped(RegExp(r'\d'), (_) => '#');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final outerBg = isDark ? AppColors.messageDark : AppColors.messageLight;
    final pillBg = isDark
        ? AppColors.grayDark
        : AppColors.messageDark.withValues(alpha: 0.05);
    final valueColor = isDark ? AppColors.messageLight : AppColors.messageDark;
    final hintColor = isDark ? AppColors.grayDark : AppColors.grayLight;
    final arrowColor = isDark ? AppColors.messageLight : AppColors.messageDark;

    final valueStyle = AppTypography.textMdRegular.copyWith(color: valueColor);
    final hintStyle = AppTypography.textMdRegular.copyWith(color: hintColor);
    final dialogTextStyle = AppTypography.textMdRegular.copyWith(
      color: isDark ? AppColors.backgroundLight : AppColors.backgroundDark,
    );

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: outerBg,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsetsDirectional.only(start: 8, end: 24),
      child: Row(
        children: [
          CountryCodePicker(
            onChanged: widget.onCountryCodeChanged,
            onInit: widget.onInit,
            initialSelection:
                widget.countryCode?.code ?? widget.initialCountryCode,
            favorite: const ['RU', 'KZ'],
            padding: EdgeInsets.zero,
            barrierColor: Colors.black.withValues(alpha: 0.5),
            dialogBackgroundColor: context.theme.scaffoldBackgroundColor,
            dialogTextStyle: dialogTextStyle,
            searchStyle: dialogTextStyle,
            builder: (code) => _CountryPill(
              code: code,
              backgroundColor: pillBg,
              arrowColor: arrowColor,
              textStyle: valueStyle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: widget.controller,
              keyboardType: TextInputType.phone,
              style: valueStyle,
              cursorColor: AppColors.brand,
              cursorWidth: 2,
              cursorRadius: const Radius.circular(10),
              cursorHeight: 20,
              onChanged: widget.onChanged,
              inputFormatters: _phoneMaskFormatter != null
                  ? [_phoneMaskFormatter!]
                  : const <TextInputFormatter>[],
              decoration: InputDecoration(
                hintText: context.s.enterPhoneNumber,
                hintStyle: hintStyle,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isCollapsed: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountryPill extends StatelessWidget {
  const _CountryPill({
    required this.code,
    required this.backgroundColor,
    required this.arrowColor,
    required this.textStyle,
  });

  final CountryCode? code;
  final Color backgroundColor;
  final Color arrowColor;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (code?.flagUri != null)
            ClipOval(
              child: Image.asset(
                code!.flagUri!,
                package: 'country_code_picker',
                width: 20,
                height: 20,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(width: 4),
          Text(code?.dialCode ?? '', style: textStyle),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down, size: 16, color: arrowColor),
        ],
      ),
    );
  }
}
