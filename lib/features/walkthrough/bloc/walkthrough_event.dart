import 'package:equatable/equatable.dart';

/// Events for walkthrough flow
abstract class WalkthroughEvent extends Equatable {
  const WalkthroughEvent();

  @override
  List<Object?> get props => [];
}

/// Event to start walkthrough for a screen
class StartWalkthrough extends WalkthroughEvent {
  final String screenName;

  const StartWalkthrough(this.screenName);

  @override
  List<Object?> get props => [screenName];
}

/// Event to move to next highlight
class NextHighlight extends WalkthroughEvent {
  const NextHighlight();
}

/// Event when user skips walkthrough
class SkipWalkthrough extends WalkthroughEvent {
  const SkipWalkthrough();
}

/// Event when walkthrough is completed
class CompleteWalkthrough extends WalkthroughEvent {
  const CompleteWalkthrough();
}
