import 'package:equatable/equatable.dart';
import '../../../../core/models/deck.dart';
import '../../../../core/models/flashcard.dart';

class DeckDetailState extends Equatable {
  final bool isLoading;
  final Deck deck;
  final List<Flashcard> flashcards;
  final String? errorMessage;

  const DeckDetailState({
    required this.deck,
    this.isLoading = false,
    this.flashcards = const [],
    this.errorMessage,
  });

  DeckDetailState copyWith({
    bool? isLoading,
    Deck? deck,
    List<Flashcard>? flashcards,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DeckDetailState(
      deck: deck ?? this.deck,
      isLoading: isLoading ?? this.isLoading,
      flashcards: flashcards ?? this.flashcards,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [isLoading, deck, flashcards, errorMessage];
}
