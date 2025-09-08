import 'package:equatable/equatable.dart';
import '../../../../core/models/deck.dart';
import '../../../../core/models/flashcard.dart';
import '../../../../core/models/deck_pack.dart';

enum DeckManagementStatus {
  initial,
  loading,
  success,
  failure,
}

class DeckManagementState extends Equatable {
  final DeckManagementStatus status;
  final List<Deck> decks;
  final List<DeckPack> deckPacks;
  final Map<String, List<Flashcard>> deckFlashcards;
  final String? errorMessage;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;

  const DeckManagementState({
    this.status = DeckManagementStatus.initial,
    this.decks = const [],
    this.deckPacks = const [],
    this.deckFlashcards = const {},
    this.errorMessage,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
  });

  DeckManagementState copyWith({
    DeckManagementStatus? status,
    List<Deck>? decks,
    List<DeckPack>? deckPacks,
    Map<String, List<Flashcard>>? deckFlashcards,
    String? errorMessage,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
  }) {
    return DeckManagementState(
      status: status ?? this.status,
      decks: decks ?? this.decks,
      deckPacks: deckPacks ?? this.deckPacks,
      deckFlashcards: deckFlashcards ?? this.deckFlashcards,
      errorMessage: errorMessage ?? this.errorMessage,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  @override
  List<Object?> get props => [
        status,
        decks,
        deckPacks,
        deckFlashcards,
        errorMessage,
        isCreating,
        isUpdating,
        isDeleting,
      ];
}

