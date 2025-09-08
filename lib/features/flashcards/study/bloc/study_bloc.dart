import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/core.dart';
import '../services/study_service.dart' as study_service;
import 'study_event.dart';
import 'study_state.dart';

class StudyBloc extends Bloc<StudyEvent, StudyState> {
  final study_service.StudyService _studyService;

  StudyBloc({required study_service.StudyService studyService})
      : _studyService = studyService,
        super(const StudyState()) {
    on<StudyStarted>(_onStudyStarted);
    on<StudyCardFlipped>(_onCardFlipped);
    on<StudyCardRated>(_onCardRated);
    on<StudyNextCard>(_onNextCard);
    on<StudyPreviousCard>(_onPreviousCard);
    on<StudySessionCompleted>(_onSessionCompleted);
    on<StudySessionPaused>(_onSessionPaused);
    on<StudySessionResumed>(_onSessionResumed);
  }

  Future<void> _onStudyStarted(StudyStarted event, Emitter<StudyState> emit) async {
    emit(state.copyWith(
      flashcards: event.flashcards,
      currentIndex: 0,
      showAnswer: false,
      isLoading: false,
      isPaused: false,
      cardsStudied: 0,
      averageScore: 0.0,
      error: null,
    ));
  }

  void _onCardFlipped(StudyCardFlipped event, Emitter<StudyState> emit) {
    emit(state.copyWith(showAnswer: event.showAnswer));
  }

  Future<void> _onCardRated(StudyCardRated event, Emitter<StudyState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));

      // Find and update the flashcard
      final updatedFlashcards = List<Flashcard>.from(state.flashcards);
      final cardIndex = updatedFlashcards.indexWhere((card) => card.id == event.cardId);
      
      if (cardIndex != -1) {
        final card = updatedFlashcards[cardIndex];
        final updatedCard = card.copyWith(
          reviewCount: card.reviewCount + 1,
          lastReviewed: DateTime.now(),
        );

        // Calculate next review date based on rating
        final nextReview = _calculateNextReviewDate(updatedCard, event.rating);
        final finalCard = updatedCard.copyWith(nextReview: nextReview);

        updatedFlashcards[cardIndex] = finalCard;
        await _studyService.updateFlashcardProgress(finalCard);

        // Calculate new average score
        final newCardsStudied = state.cardsStudied + 1;
        final newAverageScore = ((state.averageScore * state.cardsStudied) + event.rating) / newCardsStudied;

        emit(state.copyWith(
          flashcards: updatedFlashcards,
          cardsStudied: newCardsStudied,
          averageScore: newAverageScore,
          isLoading: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  void _onNextCard(StudyNextCard event, Emitter<StudyState> emit) {
    if (state.hasMoreCards) {
      emit(state.copyWith(
        currentIndex: state.currentIndex + 1,
        showAnswer: false,
      ));
    }
  }

  void _onPreviousCard(StudyPreviousCard event, Emitter<StudyState> emit) {
    if (state.currentIndex > 0) {
      emit(state.copyWith(
        currentIndex: state.currentIndex - 1,
        showAnswer: false,
      ));
    }
  }

  Future<void> _onSessionCompleted(StudySessionCompleted event, Emitter<StudyState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));
      
      await _studyService.recordStudySession(
        event.deckId,
        event.cardsStudied,
        event.averageScore,
      );

      emit(state.copyWith(
        isLoading: false,
        isPaused: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  void _onSessionPaused(StudySessionPaused event, Emitter<StudyState> emit) {
    emit(state.copyWith(isPaused: true));
  }

  void _onSessionResumed(StudySessionResumed event, Emitter<StudyState> emit) {
    emit(state.copyWith(isPaused: false));
  }

  DateTime _calculateNextReviewDate(Flashcard card, int rating) {
    final now = DateTime.now();
    
    // Simple spaced repetition algorithm
    // Rating: 1=Again, 2=Hard, 3=Good, 4=Easy
    double interval = 1.0;
    
    if (card.reviewCount > 0) {
      interval = card.interval * card.easeFactor;
    }

    switch (rating) {
      case 1: // Again
        interval = 1.0;
        break;
      case 2: // Hard
        interval *= 0.8;
        break;
      case 3: // Good
        interval *= 1.0;
        break;
      case 4: // Easy
        interval *= 1.3;
        break;
    }

    // Ensure minimum interval of 1 day
    interval = interval < 1.0 ? 1.0 : interval;

    return now.add(Duration(days: interval.round()));
  }
}
