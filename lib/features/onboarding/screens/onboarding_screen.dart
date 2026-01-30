import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../data/onboarding_data.dart';
import '../widgets/onboarding_page_widget.dart';
import '../widgets/onboarding_navigation.dart';
import '../../auth/screens/welcome_screen.dart';

/// Main onboarding screen with PageView and animations
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  double _currentPageValue = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      setState(() {
        _currentPageValue = _pageController.page ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    context.read<OnboardingBloc>().add(PageChanged(page));
  }

  void _onSkip() {
    context.read<OnboardingBloc>().add(const OnboardingSkipped());
  }

  void _onNext() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _onGetStarted() {
    context.read<OnboardingBloc>().add(const OnboardingCompleted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingCompletedState) {
            // Navigate to sign-in screen after onboarding
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const WelcomeScreen()),
            );
          }
        },
        child: BlocBuilder<OnboardingBloc, OnboardingState>(
          builder: (context, state) {
            final currentPage = state is OnboardingPageState ? state.currentPage : 0;
            final totalPages = OnboardingData.pages.length;

            return Stack(
              children: [
                // PageView with parallax effect
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: totalPages,
                  itemBuilder: (context, index) {
                    // Calculate offset for parallax effect
                    double pageOffset = 0.0;
                    if (_pageController.hasClients && _pageController.position.hasContentDimensions) {
                      pageOffset = _currentPageValue - index;
                    }

                    return OnboardingPageWidget(
                      pageData: OnboardingData.pages[index],
                      pageOffset: pageOffset,
                    );
                  },
                ),

                // Navigation at the bottom
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: OnboardingNavigation(
                    pageController: _pageController,
                    currentPage: currentPage,
                    totalPages: totalPages,
                    onSkip: _onSkip,
                    onNext: _onNext,
                    onGetStarted: _onGetStarted,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
