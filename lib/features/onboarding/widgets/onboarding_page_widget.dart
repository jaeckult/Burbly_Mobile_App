import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/onboarding_page_model.dart';

/// Widget for a single onboarding page with animations
class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPageModel pageData;
  final double pageOffset;

  const OnboardingPageWidget({
    Key? key,
    required this.pageData,
    this.pageOffset = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Parallax effect calculation
    final animationOffset = pageOffset * 100;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: pageData.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 1),
              
              // Lottie Animation with parallax
              Transform.translate(
                offset: Offset(0, -animationOffset * 0.5),
                child: Container(
                  height: screenHeight * 0.35,
                  width: screenWidth * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Lottie.asset(
                      pageData.lottieAssetPath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to icon if Lottie fails to load
                        return Icon(
                          Icons.school_rounded,
                          size: 120,
                          color: Colors.white.withOpacity(0.8),
                        );
                      },
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms).scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                      duration: 600.ms,
                      curve: Curves.easeOutBack,
                    ),
              ),
              
              const SizedBox(height: 60),
              
              // Headline with slide animation
              Transform.translate(
                offset: Offset(-animationOffset * 0.3, 0),
                child: Text(
                  pageData.headline,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ).animate().fadeIn(
                      delay: 200.ms,
                      duration: 600.ms,
                    ).slideY(
                      begin: 0.3,
                      end: 0,
                      duration: 600.ms,
                      curve: Curves.easeOut,
                    ),
              ),
              
              const SizedBox(height: 20),
              
              // Description with fade animation
              Transform.translate(
                offset: Offset(animationOffset * 0.2, 0),
                child: Text(
                  pageData.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.6,
                  ),
                ).animate().fadeIn(
                      delay: 400.ms,
                      duration: 600.ms,
                    ).slideY(
                      begin: 0.2,
                      end: 0,
                      duration: 600.ms,
                      curve: Curves.easeOut,
                    ),
              ),
              
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
