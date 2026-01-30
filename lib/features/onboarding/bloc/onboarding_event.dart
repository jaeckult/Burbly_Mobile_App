import 'package:equatable/equatable.dart';

/// Events for onboarding flow
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Event when page is changed
class PageChanged extends OnboardingEvent {
  final int pageIndex;

  const PageChanged(this.pageIndex);

  @override
  List<Object?> get props => [pageIndex];
}

/// Event when user skips onboarding
class OnboardingSkipped extends OnboardingEvent {
  const OnboardingSkipped();
}

/// Event when user completes onboarding
class OnboardingCompleted extends OnboardingEvent {
  const OnboardingCompleted();
}
