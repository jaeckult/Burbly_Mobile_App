import 'package:flutter/material.dart';

/// Model representing a single onboarding page
class OnboardingPageModel {
  /// Short headline (max 6 words)
  final String headline;
  
  /// Benefit-focused description (one sentence)
  final String description;
  
  /// Path to Lottie animation asset
  final String lottieAssetPath;
  
  /// Background gradient colors
  final List<Color> gradientColors;
  
  const OnboardingPageModel({
    required this.headline,
    required this.description,
    required this.lottieAssetPath,
    required this.gradientColors,
  });
}
