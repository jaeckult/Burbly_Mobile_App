    import 'package:flutter/material.dart';

/// Central motion configuration for consistent animations across the app.
/// Based on Material Motion guidelines.
class AppMotion {
  AppMotion._();

  // ============ DURATIONS ============
  /// Extra short for micro-interactions (press feedback, toggles)
  static const Duration durationXs = Duration(milliseconds: 100);
  
  /// Micro duration for rapid state changes
  static const Duration durationMicro = Duration(milliseconds: 150);
  
  /// Default duration for most UI animations
  static const Duration durationSm = Duration(milliseconds: 200);
  
  /// Standard page transition duration (snappy, not sluggish)
  static const Duration durationMd = Duration(milliseconds: 250);
  
  /// Navigation-specific duration (forward)
  static const Duration durationNav = Duration(milliseconds: 250);
  
  /// Navigation reverse duration (feels snappier on back)
  static const Duration durationNavReverse = Duration(milliseconds: 200);
  
  /// Longer animations (staggered lists, complex transitions)
  static const Duration durationLg = Duration(milliseconds: 350);
  
  /// Extra long for elaborate sequences
  static const Duration durationXl = Duration(milliseconds: 450);

  // ============ CURVES ============
  /// Standard easing for most animations (deceleration emphasis)
  static const Curve curveStandard = Curves.easeOutCubic;
  
  /// For elements entering the screen
  static const Curve curveEmphasizedDecelerate = Curves.easeOutQuart;
  
  /// For elements leaving the screen
  static const Curve curveEmphasizedAccelerate = Curves.easeInCubic;
  
  /// For spring-like bouncy motion
  static const Curve curveSpring = Curves.elasticOut;
  
  /// For smooth fade transitions
  static const Curve curveFade = Curves.easeInOut;

  // ============ STAGGER DELAYS ============
  /// Base delay between staggered list items
  static const Duration staggerDelay = Duration(milliseconds: 50);
  
  /// Maximum stagger for lists (prevents long waits)
  static const int maxStaggerItems = 10;

  // ============ SCALE VALUES ============
  /// Scale for entrance animations (slightly smaller to normal)
  static const double scaleEntranceStart = 0.95;
  
  /// Scale for press feedback
  static const double scalePressedDown = 0.97;
  
  /// Scale for hover/focus states
  static const double scaleHover = 1.02;

  // ============ OFFSET VALUES ============
  /// Vertical offset for slide-up entrances
  static const Offset slideUpOffset = Offset(0, 0.05);
  
  /// Horizontal offset for shared axis transitions
  static const Offset slideRightOffset = Offset(0.1, 0);
}
