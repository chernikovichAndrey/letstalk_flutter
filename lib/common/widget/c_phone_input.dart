import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_country_code_picker_sheet.dart';
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
    this.favorite = const ['RU', 'KZ'],
  });

  final TextEditingController controller;
  final CountryCode? countryCode;
  final ValueChanged<CountryCode> onCountryCodeChanged;
  final String? initialCountryCode;
  final ValueChanged<CountryCode?>? onInit;
  final ValueChanged<String>? onChanged;
  final List<String> favorite;

  @override
  State<CPhoneInput> createState() => _CPhoneInputState();
}

class _CPhoneInputState extends State<CPhoneInput> {
  MaskTextInputFormatter? _phoneMaskFormatter;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _updatePhoneMask();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    if (widget.countryCode != null) return;
    final initial = widget.initialCountryCode;
    if (initial == null) return;

    CountryCode? found;
    for (final json in codes) {
      final c = CountryCode.fromJson(json);
      if (c.code?.toUpperCase() == initial.toUpperCase() ||
          c.dialCode == initial) {
        found = c;
        break;
      }
    }
    if (found == null) return;
    found.localize(context);
    widget.onInit?.call(found);
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

  Future<void> _openCountryPicker() async {
    final selected = await CCountryCodePickerSheet.show(
      context,
      initialSelection:
          widget.countryCode?.code ?? widget.initialCountryCode,
      favorite: widget.favorite,
    );
    if (selected != null) {
      widget.onCountryCodeChanged(selected);
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

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: outerBg,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsetsDirectional.only(start: 8, end: 24),
      child: Row(
        children: [
          _CountryPill(
            code: widget.countryCode,
            backgroundColor: pillBg,
            arrowColor: arrowColor,
            textStyle: valueStyle,
            onTap: _openCountryPicker,
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
    required this.onTap,
  });

  final CountryCode? code;
  final Color backgroundColor;
  final Color arrowColor;
  final TextStyle textStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 40,
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
        ),
      ),
    );
  }
}
