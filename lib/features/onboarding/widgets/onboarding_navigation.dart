import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'pulsing_button.dart';

/// Bottom navigation bar for onboarding with Skip, Indicator, Next/Get Started
class OnboardingNavigation extends StatelessWidget {
  final PageController pageController;
  final int currentPage;
  final int totalPages;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final VoidCallback onGetStarted;

  const OnboardingNavigation({
    Key? key,
    required this.pageController,
    required this.currentPage,
    required this.totalPages,
    required this.onSkip,
    required this.onNext,
    required this.onGetStarted,
  }) : super(key: key);

  bool get isLastPage => currentPage == totalPages - 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Page Indicator
          SmoothPageIndicator(
            controller: pageController,
            count: totalPages,
            effect: ExpandingDotsEffect(
              activeDotColor: Colors.white,
              dotColor: Colors.white.withOpacity(0.3),
              dotHeight: 8,
              dotWidth: 8,
              expansionFactor: 4,
              spacing: 8,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Skip button (hidden on last page)
              if (!isLastPage)
                TextButton(
                  onPressed: onSkip,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white.withOpacity(0.8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                const SizedBox(width: 80),
              
              const Spacer(),
              
              // Next or Get Started button
              if (isLastPage)
                PulsingButton(
                  text: 'Get Started',
                  onPressed: onGetStarted,
                  isPulsing: true,
                )
              else
                PulsingButton(
                  text: 'Next',
                  onPressed: onNext,
                  isPulsing: false,
                  width: 120,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
