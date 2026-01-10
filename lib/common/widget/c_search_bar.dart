import 'package:flutter/material.dart';
import 'package:lets_talk/common/widget/c_text_field.dart';

class CSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final EdgeInsetsGeometry padding;

  const CSearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: CTextField(
        hintText: hintText,
        onChanged: onChanged,
        prefixIcon: const Icon(Icons.search),
      ),
    );
  }
}
