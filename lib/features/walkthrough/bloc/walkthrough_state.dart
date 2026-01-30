import 'package:equatable/equatable.dart';

/// States for walkthrough flow
abstract class WalkthroughState extends Equatable {
  const WalkthroughState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no walkthrough active
class WalkthroughInactive extends WalkthroughState {
  const WalkthroughInactive();
}

/// State when walkthrough is checking if it should show
class WalkthroughChecking extends WalkthroughState {
  final String screenName;

  const WalkthroughChecking(this.screenName);

  @override
  List<Object?> get props => [screenName];
}

/// State when walkthrough is active
class WalkthroughActive extends WalkthroughState {
  final String screenName;
  final int currentHighlight;
  final int totalHighlights;
  final bool isLastHighlight;

  const WalkthroughActive({
    required this.screenName,
    required this.currentHighlight,
    required this.totalHighlights,
  }) : isLastHighlight = currentHighlight == totalHighlights - 1;

  @override
  List<Object?> get props => [screenName, currentHighlight, totalHighlights];
}

/// State when walkthrough is completed
class WalkthroughCompleted extends WalkthroughState {
  final String screenName;

  const WalkthroughCompleted(this.screenName);

  @override
  List<Object?> get props => [screenName];
}
