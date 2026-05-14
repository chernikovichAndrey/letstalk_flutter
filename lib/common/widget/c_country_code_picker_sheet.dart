import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

/// Country code picker bottom sheet from Figma design "phone"
/// (light node 996:31303 / dark node 996:31430).
///
/// Full-height modal with a header, pill-shaped search field, and a list of
/// countries with a flag, dial code, and localized name on each row.
class CCountryCodePickerSheet extends StatefulWidget {
  const CCountryCodePickerSheet({
    super.key,
    this.initialSelection,
    this.favorite = const [],
    this.countryList = codes,
  });

  final String? initialSelection;
  final List<String> favorite;
  final List<Map<String, String>> countryList;

  static Future<CountryCode?> show(
    BuildContext context, {
    String? initialSelection,
    List<String> favorite = const [],
    List<Map<String, String>> countryList = codes,
  }) {
    return showModalBottomSheet<CountryCode>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xCC232323),
      useSafeArea: true,
      builder: (_) => CCountryCodePickerSheet(
        initialSelection: initialSelection,
        favorite: favorite,
        countryList: countryList,
      ),
    );
  }

  @override
  State<CCountryCodePickerSheet> createState() =>
      _CCountryCodePickerSheetState();
}

class _CCountryCodePickerSheetState extends State<CCountryCodePickerSheet> {
  late final TextEditingController _searchController;
  late final List<CountryCode> _all;
  late final List<CountryCode> _favorites;
  String _query = '';
  bool _localized = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _all = widget.countryList
        .map((json) => CountryCode.fromJson(json))
        .toList();
    final favoriteSet = widget.favorite
        .map((e) => e.toUpperCase())
        .toSet();
    _favorites = _all
        .where(
          (item) =>
              favoriteSet.contains(item.code?.toUpperCase()) ||
              favoriteSet.contains(item.dialCode) ||
              favoriteSet.contains(item.name?.toUpperCase()),
        )
        .toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_localized) return;
    for (final element in _all) {
      element.localize(context);
    }
    _localized = true;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CountryCode> get _filtered {
    if (_query.isEmpty) return _all;
    final lower = _query.toLowerCase();
    return _all.where((c) {
      final name = c.name?.toLowerCase() ?? '';
      final dial = c.dialCode?.toLowerCase() ?? '';
      final code = c.code?.toLowerCase() ?? '';
      return name.contains(lower) ||
          dial.contains(lower) ||
          code.contains(lower);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sheetBg = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final titleColor = isDark
        ? AppColors.messageLight
        : AppColors.messageDark;
    final iconColor = isDark ? AppColors.messageLight : AppColors.messageDark;
    final searchBg = isDark ? AppColors.messageDark : AppColors.messageLight;
    final searchHintColor = isDark
        ? AppColors.grayDark
        : AppColors.grayLight;
    final searchTextColor = isDark
        ? AppColors.messageLight
        : AppColors.messageDark;
    final separatorColor = isDark
        ? AppColors.messageDark
        : AppColors.messageLight;
    final itemTextColor = isDark
        ? AppColors.messageLight
        : AppColors.messageDark;

    final filtered = _filtered;
    final showFavorites = _query.isEmpty && _favorites.isNotEmpty;

    return FractionallySizedBox(
      heightFactor: 0.94,
      child: Container(
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _Header(title: context.s.selectCountryCode, color: titleColor, iconColor: iconColor),
            const SizedBox(height: 8),
            _SearchField(
              controller: _searchController,
              backgroundColor: searchBg,
              hintColor: searchHintColor,
              textColor: searchTextColor,
              hintText: context.s.search,
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(
                  left: 16,
                  bottom: MediaQuery.paddingOf(context).bottom + 8,
                ),
                itemCount: filtered.length + (showFavorites ? _favorites.length : 0),
                itemBuilder: (context, index) {
                  final isFavoriteSection = showFavorites && index < _favorites.length;
                  final country = isFavoriteSection
                      ? _favorites[index]
                      : filtered[index - (showFavorites ? _favorites.length : 0)];
                  return _CountryRow(
                    country: country,
                    textColor: itemTextColor,
                    separatorColor: separatorColor,
                    onTap: () => Navigator.of(context).pop(country),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.color,
    required this.iconColor,
  });

  final String title;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        children: [
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.textLgMedium.copyWith(color: color),
            ),
          ),
          SizedBox(
            width: 24,
            height: 24,
            child: InkResponse(
              onTap: () => Navigator.of(context).pop(),
              radius: 18,
              child: Icon(Icons.close, size: 24, color: iconColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.backgroundColor,
    required this.hintColor,
    required this.textColor,
    required this.hintText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final Color backgroundColor;
  final Color hintColor;
  final Color textColor;
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final hintStyle = AppTypography.textMdRegular.copyWith(color: hintColor);
    final textStyle = AppTypography.textMdRegular.copyWith(color: textColor);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.search, size: 24, color: hintColor),
            const SizedBox(width: 4),
            Expanded(
              child: TextField(
                controller: controller,
                style: textStyle,
                cursorColor: AppColors.brand,
                cursorWidth: 2,
                cursorRadius: const Radius.circular(10),
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: hintText,
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
      ),
    );
  }
}

class _CountryRow extends StatelessWidget {
  const _CountryRow({
    required this.country,
    required this.textColor,
    required this.separatorColor,
    required this.onTap,
  });

  final CountryCode country;
  final Color textColor;
  final Color separatorColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textStyle = AppTypography.textMdRegular.copyWith(color: textColor);

    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 52,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  if (country.flagUri != null)
                    ClipOval(
                      child: Image.asset(
                        country.flagUri!,
                        package: 'country_code_picker',
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    const SizedBox(width: 24, height: 24),
                  const SizedBox(width: 8),
                  Text(country.dialCode ?? '', style: textStyle),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      country.toCountryStringOnly(),
                      style: textStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Container(height: 1, color: separatorColor),
          ),
        ],
      ),
    );
  }
}
