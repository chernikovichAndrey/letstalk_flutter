import 'package:flutter/material.dart';
import 'package:lets_talk/app/router/route_type.dart';
import 'package:lets_talk/app/router/custom_page_routes/custom_cupertino_sheet.dart';

/// Wrapper above [RouteType] for RouterApi
class CPage extends Page {
  const CPage({
    required this.child,
    required this.type,
    this.barrierDismissible,
    super.key,
    super.canPop,
    super.name,
    super.arguments,
  });

  final Widget child;
  final RouteType type;
  final bool? barrierDismissible;

  @override
  Route createRoute(final BuildContext context) {
    switch (type) {
      case RouteType.dialog:
        return RawDialogRoute(
          settings: this,
          barrierDismissible: barrierDismissible ?? false,
          pageBuilder: (final _, final animation, final _) {
            return AnimatedBuilder(
              builder: (final _, final _) => child,
              animation: animation,
            );
          },
        );
      case RouteType.sheet:
        return CupertinoSheetRoute(builder: (_) => child, settings: this);

      case RouteType.page:
        return MaterialPageRoute(
          settings: this,
          builder: (BuildContext context) => child,
        );
      case RouteType.bottomSheet:
        return ModalBottomSheetRoute(
          settings: this,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (BuildContext context) => child,
        );
    }
  }
}
