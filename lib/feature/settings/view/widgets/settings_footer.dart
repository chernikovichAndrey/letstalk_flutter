import 'package:flutter/material.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsFooter extends StatefulWidget {
  const SettingsFooter({super.key});

  @override
  State<SettingsFooter> createState() => _SettingsFooterState();
}

class _SettingsFooterState extends State<SettingsFooter> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _version = '${packageInfo.version}(${packageInfo.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final linkColor = isDark ? AppColors.grayDark : AppColors.grayLight;

    final linkStyle = TextStyle(
      color: linkColor,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.3,
      decoration: TextDecoration.none,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => context.push(Routes.privacyPolicy),
          child: Text(context.s.privacyPolicy, style: linkStyle),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => context.push(Routes.termsOfService),
          child: Text(context.s.termsOfService, style: linkStyle),
        ),
        if (_version.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '${context.s.version} $_version',
            style: linkStyle.copyWith(
              color: linkColor.withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}
