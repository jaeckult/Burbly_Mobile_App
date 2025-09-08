import 'package:equatable/equatable.dart';
import '../../../../core/models/deck.dart';
import '../../../../core/models/flashcard.dart';

abstract class DeckDetailEvent extends Equatable {
  const DeckDetailEvent();
  @override
  List<Object?> get props => [];
}

class InitializeDeck extends DeckDetailEvent {
  final Deck deck;
  const InitializeDeck(this.deck);
  @override
  List<Object?> get props => [deck];
}

class RefreshRequested extends DeckDetailEvent {
  const RefreshRequested();
}

class PeriodicTick extends DeckDetailEvent {
  const PeriodicTick();
}

class LoadFlashcards extends DeckDetailEvent {
  const LoadFlashcards();
}

class ToggleSpacedRepetition extends DeckDetailEvent {
  final bool enabled;
  const ToggleSpacedRepetition(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class ToggleShowStudyStats extends DeckDetailEvent {
  final bool visible;
  const ToggleShowStudyStats(this.visible);
  @override
  List<Object?> get props => [visible];
}

class UpdateTimerDuration extends DeckDetailEvent {
  final int? seconds;
  const UpdateTimerDuration(this.seconds);
  @override
  List<Object?> get props => [seconds];
}

class EditDeckRequested extends DeckDetailEvent {
  final String name;
  final String description;
  final String? coverColor;
  const EditDeckRequested({required this.name, required this.description, this.coverColor});
  @override
  List<Object?> get props => [name, description, coverColor];
}

class EditFlashcardRequested extends DeckDetailEvent {
  final Flashcard flashcard;
  const EditFlashcardRequested(this.flashcard);
  @override
  List<Object?> get props => [flashcard];
}

class DeleteFlashcardRequested extends DeckDetailEvent {
  final String flashcardId;
  const DeleteFlashcardRequested(this.flashcardId);
  @override
  List<Object?> get props => [flashcardId];
}
