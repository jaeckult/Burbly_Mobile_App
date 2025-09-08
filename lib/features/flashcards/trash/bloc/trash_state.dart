import 'package:equatable/equatable.dart';
import '../../../../core/core.dart';

class TrashState extends Equatable {
  final bool isLoading;
  final List<Deck> deletedDecks;
  final List<Flashcard> deletedFlashcards;
  final List<Note> deletedNotes;
  final Map<String, int> counts;
  final String? errorMessage;

  const TrashState({
    this.isLoading = false,
    this.deletedDecks = const [],
    this.deletedFlashcards = const [],
    this.deletedNotes = const [],
    this.counts = const {'decks': 0, 'flashcards': 0, 'notes': 0, 'total': 0},
    this.errorMessage,
  });

  TrashState copyWith({
    bool? isLoading,
    List<Deck>? deletedDecks,
    List<Flashcard>? deletedFlashcards,
    List<Note>? deletedNotes,
    Map<String, int>? counts,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TrashState(
      isLoading: isLoading ?? this.isLoading,
      deletedDecks: deletedDecks ?? this.deletedDecks,
      deletedFlashcards: deletedFlashcards ?? this.deletedFlashcards,
      deletedNotes: deletedNotes ?? this.deletedNotes,
      counts: counts ?? this.counts,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        deletedDecks,
        deletedFlashcards,
        deletedNotes,
        counts,
        errorMessage,
      ];
}
