import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/glass_app_bar_background.dart';
import 'package:lets_talk/common/widget/glass_button.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum LegalDocumentType {
  privacyPolicy,
  termsOfService,
}

class HtmlDocumentPage extends StatefulWidget {
  final String locale;
  final LegalDocumentType documentType;

  const HtmlDocumentPage({
    super.key,
    required this.locale,
    required this.documentType,
  });

  @override
  State<HtmlDocumentPage> createState() => _HtmlDocumentPageState();
}

class _HtmlDocumentPageState extends State<HtmlDocumentPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      );

    final htmlPath = _getHtmlPath();
    final htmlContent = await rootBundle.loadString(htmlPath);
    await _controller.loadHtmlString(htmlContent);
  }

  String _getHtmlPath() {
    final localeCode = widget.locale.toLowerCase();
    final documentPrefix = switch (widget.documentType) {
      LegalDocumentType.privacyPolicy => 'privacy_policy',
      LegalDocumentType.termsOfService => 'terms_of_service',
    };

    switch (localeCode) {
      case 'en':
        return 'assets/html/${documentPrefix}_en.html';
      case 'kk':
        return 'assets/html/${documentPrefix}_kk.html';
      case 'ru':
      default:
        return 'assets/html/${documentPrefix}_ru.html';
    }
  }

  String _getTitle() {
    return switch (widget.documentType) {
      LegalDocumentType.privacyPolicy => context.s.privacyPolicy,
      LegalDocumentType.termsOfService => context.s.termsOfService,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            child: WebViewWidget(controller: _controller),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: Stack(
                  children: [
                    const Positioned.fill(child: GlassAppBarBackground()),
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GlassButton(
                              icon: Icons.close,
                              onTap: context.pop,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
