import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/onboarding_service.dart';
import '../../../core/utils/logger.dart';
import 'walkthrough_event.dart';
import 'walkthrough_state.dart';

/// BLoC for managing walkthrough state
class WalkthroughBloc extends Bloc<WalkthroughEvent, WalkthroughState> {
  final OnboardingService _onboardingService;
  int _totalHighlights = 0;

  WalkthroughBloc(this._onboardingService) : super(const WalkthroughInactive()) {
    on<StartWalkthrough>(_onStartWalkthrough);
    on<NextHighlight>(_onNextHighlight);
    on<SkipWalkthrough>(_onSkipWalkthrough);
    on<CompleteWalkthrough>(_onCompleteWalkthrough);
  }

  Future<void> _onStartWalkthrough(
    StartWalkthrough event,
    Emitter<WalkthroughState> emit,
  ) async {
    try {
      emit(WalkthroughChecking(event.screenName));
      
      // Check if walkthrough was already completed
      final completed = await _onboardingService.isWalkthroughCompleted(event.screenName);
      
      if (!completed) {
        // Start walkthrough
        emit(WalkthroughActive(
          screenName: event.screenName,
          currentHighlight: 0,
          totalHighlights: _totalHighlights,
        ));
        AppLogger.info('Walkthrough started for ${event.screenName}');
      } else {
        emit(const WalkthroughInactive());
        AppLogger.info('Walkthrough already completed for ${event.screenName}');
      }
    } catch (e) {
      AppLogger.error('Error starting walkthrough', error: e);
      emit(const WalkthroughInactive());
    }
  }

  void _onNextHighlight(
    NextHighlight event,
    Emitter<WalkthroughState> emit,
  ) {
    if (state is WalkthroughActive) {
      final currentState = state as WalkthroughActive;
      final nextIndex = currentState.currentHighlight + 1;
      
      if (nextIndex < currentState.totalHighlights) {
        emit(WalkthroughActive(
          screenName: currentState.screenName,
          currentHighlight: nextIndex,
          totalHighlights: currentState.totalHighlights,
        ));
      } else {
        // Last highlight, complete walkthrough
        add(const CompleteWalkthrough());
      }
    }
  }

  Future<void> _onSkipWalkthrough(
    SkipWalkthrough event,
    Emitter<WalkthroughState> emit,
  ) async {
    if (state is WalkthroughActive) {
      final currentState = state as WalkthroughActive;
      
      try {
        await _onboardingService.completeWalkthrough(currentState.screenName);
        AppLogger.info('Walkthrough skipped for ${currentState.screenName}');
        emit(WalkthroughCompleted(currentState.screenName));
      } catch (e) {
        AppLogger.error('Error skipping walkthrough', error: e);
        emit(WalkthroughCompleted(currentState.screenName));
      }
    }
  }

  Future<void> _onCompleteWalkthrough(
    CompleteWalkthrough event,
    Emitter<WalkthroughState> emit,
  ) async {
    if (state is WalkthroughActive) {
      final currentState = state as WalkthroughActive;
      
      try {
        await _onboardingService.completeWalkthrough(currentState.screenName);
        AppLogger.info('Walkthrough completed for ${currentState.screenName}');
        emit(WalkthroughCompleted(currentState.screenName));
      } catch (e) {
        AppLogger.error('Error completing walkthrough', error: e);
        emit(WalkthroughCompleted(currentState.screenName));
      }
    }
  }

  /// Set total highlights for the walkthrough
  void setTotalHighlights(int total) {
    _totalHighlights = total;
  }
}
