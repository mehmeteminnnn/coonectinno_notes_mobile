import 'package:flutter/material.dart';

class SlideRightRoute extends PageRouteBuilder {
  final Widget page;
  final Offset begin;
  final Offset end;

  SlideRightRoute({
    required this.page,
    this.begin = const Offset(1.0, 0.0),
    this.end = Offset.zero,
  }) : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            final curveTween = CurveTween(curve: Curves.easeInOutCubic);
            final tween = Tween(begin: begin, end: end).chain(curveTween);
            final offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}

class FadeRoute extends PageRouteBuilder {
  final Widget page;

  FadeRoute({required this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
        );
}

class ScaleRoute extends PageRouteBuilder {
  final Widget page;
  final double scaleStart;
  final double scaleEnd;

  ScaleRoute({
    required this.page,
    this.scaleStart = 0.8,
    this.scaleEnd = 1.0,
  }) : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            return ScaleTransition(
              scale: Tween<double>(
                begin: scaleStart,
                end: scaleEnd,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutBack,
                ),
              ),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}

class SlideUpRoute extends PageRouteBuilder {
  final Widget page;
  final Offset begin;
  final Offset end;

  SlideUpRoute({
    required this.page,
    this.begin = const Offset(0.0, 1.0),
    this.end = Offset.zero,
  }) : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            final curveTween = CurveTween(curve: Curves.easeInOutCubic);
            final tween = Tween(begin: begin, end: end).chain(curveTween);
            final offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}

class HeroDialogRoute<T> extends PageRoute<T> {
  HeroDialogRoute({
    required this.builder,
    this.barrierColor = Colors.black54,
    this.barrierDismissible = true,
    this.barrierLabel,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.opaque = false,
  });

  final WidgetBuilder builder;
  final Color? barrierColor;
  final bool barrierDismissible;
  final String? barrierLabel;
  final Duration transitionDuration;
  final bool opaque;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      ),
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutBack,
          ),
        ),
        child: child,
      ),
    );
  }
}
