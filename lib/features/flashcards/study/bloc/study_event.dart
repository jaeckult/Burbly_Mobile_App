import 'package:equatable/equatable.dart';
import '../../../../core/core.dart';

abstract class StudyEvent extends Equatable {
  const StudyEvent();

  @override
  List<Object?> get props => [];
}

class StudyStarted extends StudyEvent {
  final String deckId;
  final List<Flashcard> flashcards;

  const StudyStarted({
    required this.deckId,
    required this.flashcards,
  });

  @override
  List<Object?> get props => [deckId, flashcards];
}

class StudyCardFlipped extends StudyEvent {
  final bool showAnswer;

  const StudyCardFlipped({required this.showAnswer});

  @override
  List<Object?> get props => [showAnswer];
}

class StudyCardRated extends StudyEvent {
  final int rating;
  final String cardId;

  const StudyCardRated({
    required this.rating,
    required this.cardId,
  });

  @override
  List<Object?> get props => [rating, cardId];
}

class StudyNextCard extends StudyEvent {
  const StudyNextCard();
}

class StudyPreviousCard extends StudyEvent {
  const StudyPreviousCard();
}

class StudySessionCompleted extends StudyEvent {
  final String deckId;
  final int cardsStudied;
  final double averageScore;

  const StudySessionCompleted({
    required this.deckId,
    required this.cardsStudied,
    required this.averageScore,
  });

  @override
  List<Object?> get props => [deckId, cardsStudied, averageScore];
}

class StudySessionPaused extends StudyEvent {
  const StudySessionPaused();
}

class StudySessionResumed extends StudyEvent {
  const StudySessionResumed();
}

