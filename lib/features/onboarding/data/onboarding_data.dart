import 'package:flutter/material.dart';
import '../models/onboarding_page_model.dart';

/// Sample onboarding data for 3 screens
class OnboardingData {
  static final List<OnboardingPageModel> pages = [
    // Page 1: Smart Learning
    const OnboardingPageModel(
      headline: 'Learn Smarter, Not Harder',
      description: 'Master any subject with scientifically-proven spaced repetition that adapts to your learning pace.',
      lottieAssetPath: 'assets/animations/onboarding_1.json',
      gradientColors: [
        Color(0xFF667eea), // Purple-blue
        Color(0xFF764ba2), // Deep purple
      ],
    ),
    
    // Page 2: Progress Tracking
    const OnboardingPageModel(
      headline: 'Track Your Progress',
      description: 'Watch your knowledge grow with detailed statistics and insights that keep you motivated.',
      lottieAssetPath: 'assets/animations/onboarding_2.json',
      gradientColors: [
        Color(0xFFf093fb), // Pink
        Color(0xFFf5576c), // Coral
      ],
    ),
    
    // Page 3: Study Anywhere
    const OnboardingPageModel(
      headline: 'Study Anywhere, Anytime',
      description: 'Your personalized study companion works offline and syncs across all your devices.',
      lottieAssetPath: 'assets/animations/onboarding_3.json',
      gradientColors: [
        Color(0xFF4facfe), // Light blue
        Color(0xFF00f2fe), // Cyan
      ],
    ),
  ];
}
