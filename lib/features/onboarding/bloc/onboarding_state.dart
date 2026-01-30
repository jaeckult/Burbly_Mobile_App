import 'package:equatable/equatable.dart';

/// States for onboarding flow
abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

/// State when viewing a specific page
class OnboardingPageState extends OnboardingState {
  final int currentPage;
  final int totalPages;
  final bool isLastPage;

  const OnboardingPageState({
    required this.currentPage,
    required this.totalPages,
  }) : isLastPage = currentPage == totalPages - 1;

  @override
  List<Object?> get props => [currentPage, totalPages];
}

/// State when onboarding is being completed
class OnboardingCompleting extends OnboardingState {
  const OnboardingCompleting();
}

/// State when onboarding is successfully completed
class OnboardingCompletedState extends OnboardingState {
  const OnboardingCompletedState();
}
