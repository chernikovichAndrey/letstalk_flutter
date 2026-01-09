import 'package:flutter/material.dart';

class CustomMaterialPageRoute<T> extends PageRoute<T>
    with CustomMaterialRouteTransitionMixin<T> {
  /// Construct a MaterialPageRoute whose contents are defined by [builder].
  CustomMaterialPageRoute({
    required this.builder,
    super.settings,
    super.requestFocus,
    this.maintainState = true,
    super.fullscreenDialog,
    super.allowSnapshotting = true,
    super.barrierDismissible = false,
    super.traversalEdgeBehavior,
    super.directionalTraversalEdgeBehavior,
    required this.transitionBuilder,
  }) {
    assert(opaque);
  }

  /// Builds the primary contents of the route.
  final WidgetBuilder builder;
  final PageTransitionsBuilder transitionBuilder;

  @override
  Widget buildContent(BuildContext context) => builder(context);

  @override
  final bool maintainState;

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';

  @override
  Duration get transitionDuration =>
      _getPageTransitionBuilder(navigator!.context)?.transitionDuration ??
      const Duration(microseconds: 300);

  @override
  Duration get reverseTransitionDuration =>
      _getPageTransitionBuilder(navigator!.context)
          ?.reverseTransitionDuration ??
      const Duration(microseconds: 300);

  PageTransitionsBuilder? _getPageTransitionBuilder(BuildContext context) {
    return transitionBuilder;
  }

  @override
  DelegatedTransitionBuilder? get delegatedTransition {
    return (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      bool allowSnapshotting,
      Widget? child,
    ) {
      final PageTransitionsTheme theme = PageTransitionsTheme(builders: {
        for (var e in TargetPlatform.values) e: transitionBuilder,
      });
      final TargetPlatform platform = Theme.of(context).platform;
      final DelegatedTransitionBuilder? themeDelegatedTransition =
          theme.delegatedTransition(
        platform,
      );
      return themeDelegatedTransition != null
          ? themeDelegatedTransition(
              context, animation, secondaryAnimation, allowSnapshotting, child)
          : null;
    };
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return transitionBuilder.buildTransitions<T>(
        this, context, animation, secondaryAnimation, child);
  }
}

/// A mixin that provides platform-adaptive transitions for a [PageRoute].
///
/// {@template flutter.material.materialRouteTransitionMixin}
/// For Android, the entrance transition for the page zooms in and fades in
/// while the exiting page zooms out and fades out. The exit transition is similar,
/// but in reverse.
///
/// For iOS, the page slides in from the right and exits in reverse. The page
/// also shifts to the left in parallax when another page enters to cover it.
/// (These directions are flipped in environments with a right-to-left reading
/// direction.)
/// {@endtemplate}
///
/// See also:
///
///  * [PageTransitionsTheme], which defines the default page transitions used
///    by the [MaterialRouteTransitionMixin.buildTransitions].
///  * [ZoomPageTransitionsBuilder], which is the default page transition used
///    by the [PageTransitionsTheme].
///  * [CupertinoPageTransitionsBuilder], which is the default page transition
///    for iOS and macOS.
mixin CustomMaterialRouteTransitionMixin<T> on PageRoute<T> {
  /// Builds the primary contents of the route.
  @protected
  Widget buildContent(BuildContext context);

  // The transitionDuration is used to create the AnimationController which is only
  // built once, so when page transition builder is updated and transitionDuration
  // has a new value, the AnimationController cannot be updated automatically. So we
  // manually update its duration here.
  // TODO(quncCccccc): Clean up this override method when controller can be updated as the transitionDuration is changed.
  @override
  TickerFuture didPush() {
    controller?.duration = transitionDuration;
    return super.didPush();
  }

  // The reverseTransitionDuration is used to create the AnimationController
  // which is only built once, so when page transition builder is updated and
  // reverseTransitionDuration has a new value, the AnimationController cannot
  // be updated automatically. So we manually update its reverseDuration here.
  // TODO(quncCccccc): Clean up this override method when controller can beupdated as the reverseTransitionDuration is changed.
  @override
  bool didPop(T? result) {
    controller?.reverseDuration = reverseTransitionDuration;
    return super.didPop(result);
  }

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    // Don't perform outgoing animation if the next route is a fullscreen dialog,
    // or there is no matching transition to use.
    // Don't perform outgoing animation if the next route is a fullscreen dialog.
    final bool nextRouteIsNotFullscreen =
        (nextRoute is! PageRoute<T>) || !nextRoute.fullscreenDialog;

    // If the next route has a delegated transition, then this route is able to
    // use that delegated transition to smoothly sync with the next route's
    // transition.
    final bool nextRouteHasDelegatedTransition =
        nextRoute is ModalRoute<T> && nextRoute.delegatedTransition != null;

    // Otherwise if the next route has the same route transition mixin as this
    // one, then this route will already be synced with its transition.
    return nextRouteIsNotFullscreen &&
        ((nextRoute is MaterialRouteTransitionMixin) ||
            nextRouteHasDelegatedTransition);
  }

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) {
    // Supress previous route from transitioning if this is a fullscreenDialog route.
    return previousRoute is PageRoute && !fullscreenDialog;
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final Widget result = buildContent(context);
    return Semantics(
        scopesRoute: true, explicitChildNodes: true, child: result);
  }
}
