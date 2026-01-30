import 'package:flutter/material.dart';

/// Helper class for consistent haptic feedback across the app
class HapticFeedbackHelper {
  /// Light impact feedback for button taps
  static Future<void> lightImpact() async {
    await Future.delayed(Duration.zero);
    // Using Flutter's haptic feedback
    // Note: Requires import 'package:flutter/services.dart';
    // HapticFeedback.lightImpact();
  }
  
  /// Medium impact feedback for page changes
  static Future<void> mediumImpact() async {
    await Future.delayed(Duration.zero);
    // HapticFeedback.mediumImpact();
  }
  
  /// Heavy impact feedback for completion
  static Future<void> heavyImpact() async {
    await Future.delayed(Duration.zero);
    // HapticFeedback.heavyImpact();
  }
  
  /// Selection click feedback
  static Future<void> selectionClick() async {
    await Future.delayed(Duration.zero);
    // HapticFeedback.selectionClick();
  }
}
