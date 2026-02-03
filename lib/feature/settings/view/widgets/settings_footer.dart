import 'package:flutter/cupertino.dart';
import 'package:lets_talk/app/router/routes.dart';
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
    setState(() {
      _version = '${packageInfo.version}(${packageInfo.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_version.isNotEmpty)
          Text(
            '${context.s.version} $_version',
            style: context.theme.textTheme.bodySmall?.copyWith(
              color: context.color.onSurface.withOpacity(0.6),
            ),
          ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            context.push(Routes.termsOfService);
          },
          child: Text(
            context.s.termsOfService,
            style: context.theme.textTheme.bodySmall?.copyWith(
              color: context.appColors.telegramBlue,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            context.push(Routes.privacyPolicy);
          },
          child: Text(
            context.s.privacyPolicy,
            style: context.theme.textTheme.bodySmall?.copyWith(
              color: context.appColors.telegramBlue,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
}
