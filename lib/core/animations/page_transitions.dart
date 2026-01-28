import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'motion_config.dart';

/// Global page transition configuration for MaterialApp.
/// Uses SharedAxisTransition for consistent navigation feel.
class AppPageTransitions {
  AppPageTransitions._();

  /// Page transitions theme to apply at MaterialApp level
  static PageTransitionsTheme get theme {
    return PageTransitionsTheme(
      builders: {
        // Android: Shared Axis X (horizontal slide + fade)
        TargetPlatform.android: const SharedAxisPageTransitionsBuilder(
          transitionType: SharedAxisTransitionType.horizontal,
          fillColor: Colors.transparent,
        ),
        // iOS: Cupertino-style slide
        TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
        // Web/Desktop: Fade Through
        TargetPlatform.linux: const FadeThroughPageTransitionsBuilder(),
        TargetPlatform.macOS: const CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: const FadeThroughPageTransitionsBuilder(),
      },
    );
  }
}

/// Custom SharedAxis builder with configurable duration
class SharedAxisPageTransitionsBuilder extends PageTransitionsBuilder {
  final SharedAxisTransitionType transitionType;
  final Color? fillColor;

  const SharedAxisPageTransitionsBuilder({
    this.transitionType = SharedAxisTransitionType.horizontal,
    this.fillColor,
  });

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SharedAxisTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      transitionType: transitionType,
      fillColor: fillColor ?? Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }
}

/// Fade Through builder for smooth content transitions
class FadeThroughPageTransitionsBuilder extends PageTransitionsBuilder {
  const FadeThroughPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeThroughTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      fillColor: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }
}

/// Container transform for opening detail views
/// Usage: Wrap source widget with this for material container morph
class OpenContainerTransform extends StatelessWidget {
  final Widget closedChild;
  final Widget Function(BuildContext, void Function()) openBuilder;
  final Color? closedColor;
  final double closedElevation;
  final ShapeBorder? closedShape;

  const OpenContainerTransform({
    super.key,
    required this.closedChild,
    required this.openBuilder,
    this.closedColor,
    this.closedElevation = 0,
    this.closedShape,
  });

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionDuration: AppMotion.durationMd,
      openColor: Theme.of(context).scaffoldBackgroundColor,
      closedColor: closedColor ?? Theme.of(context).cardColor,
      closedElevation: closedElevation,
      closedShape: closedShape ?? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      closedBuilder: (context, openContainer) => GestureDetector(
        onTap: openContainer,
        child: closedChild,
      ),
      openBuilder: openBuilder,
    );
  }
}
