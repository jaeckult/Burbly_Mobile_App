import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/onboarding_service.dart';
import '../../../core/utils/logger.dart';
import '../data/onboarding_data.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

/// BLoC for managing onboarding state
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final OnboardingService _onboardingService;
  final int totalPages = OnboardingData.pages.length;

  OnboardingBloc(this._onboardingService) : super(const OnboardingInitial()) {
    on<PageChanged>(_onPageChanged);
    on<OnboardingSkipped>(_onSkipped);
    on<OnboardingCompleted>(_onCompleted);

    // Initialize with first page
    add(const PageChanged(0));
  }

  void _onPageChanged(PageChanged event, Emitter<OnboardingState> emit) {
    emit(OnboardingPageState(
      currentPage: event.pageIndex,
      totalPages: totalPages,
    ));
  }

  Future<void> _onSkipped(
    OnboardingSkipped event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      emit(const OnboardingCompleting());
      await _onboardingService.completeOnboarding();
      AppLogger.info('Onboarding skipped');
      emit(const OnboardingCompletedState());
    } catch (e) {
      AppLogger.error('Error skipping onboarding', error: e);
      // Still complete even on error
      emit(const OnboardingCompletedState());
    }
  }

  Future<void> _onCompleted(
    OnboardingCompleted event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      emit(const OnboardingCompleting());
      await _onboardingService.completeOnboarding();
      AppLogger.info('Onboarding completed');
      emit(const OnboardingCompletedState());
    } catch (e) {
      AppLogger.error('Error completing onboarding', error: e);
      // Still complete even on error
      emit(const OnboardingCompletedState());
    }
  }
}
