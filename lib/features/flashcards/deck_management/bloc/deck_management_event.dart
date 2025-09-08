import 'package:equatable/equatable.dart';
import '../../../../core/models/deck.dart';
import '../../../../core/models/flashcard.dart';
import '../../../../core/models/deck_pack.dart';

abstract class DeckManagementEvent extends Equatable {
  const DeckManagementEvent();

  @override
  List<Object?> get props => [];
}

class LoadDecks extends DeckManagementEvent {
  const LoadDecks();
}

class LoadDeckPacks extends DeckManagementEvent {
  const LoadDeckPacks();
}

class CreateDeck extends DeckManagementEvent {
  final String name;
  final String description;
  final String? packId;
  final String? coverColor;

  const CreateDeck({
    required this.name,
    required this.description,
    this.packId,
    this.coverColor,
  });

  @override
  List<Object?> get props => [name, description, packId, coverColor];
}

class CreateDeckPack extends DeckManagementEvent {
  final String name;
  final String description;
  final String coverColor;

  const CreateDeckPack({
    required this.name,
    required this.description,
    required this.coverColor,
  });

  @override
  List<Object?> get props => [name, description, coverColor];
}

class UpdateDeck extends DeckManagementEvent {
  final Deck deck;

  const UpdateDeck(this.deck);

  @override
  List<Object?> get props => [deck];
}

class UpdateDeckPack extends DeckManagementEvent {
  final DeckPack deckPack;

  const UpdateDeckPack(this.deckPack);

  @override
  List<Object?> get props => [deckPack];
}

class DeleteDeck extends DeckManagementEvent {
  final String deckId;

  const DeleteDeck(this.deckId);

  @override
  List<Object?> get props => [deckId];
}

class DeleteDeckPack extends DeckManagementEvent {
  final String packId;

  const DeleteDeckPack(this.packId);

  @override
  List<Object?> get props => [packId];
}

class AddFlashcard extends DeckManagementEvent {
  final String deckId;
  final String question;
  final String answer;
  final String? hint;

  const AddFlashcard({
    required this.deckId,
    required this.question,
    required this.answer,
    this.hint,
  });

  @override
  List<Object?> get props => [deckId, question, answer, hint];
}

class UpdateFlashcard extends DeckManagementEvent {
  final Flashcard flashcard;

  const UpdateFlashcard(this.flashcard);

  @override
  List<Object?> get props => [flashcard];
}

class DeleteFlashcard extends DeckManagementEvent {
  final String flashcardId;

  const DeleteFlashcard(this.flashcardId);

  @override
  List<Object?> get props => [flashcardId];
}

class MoveDeckToPack extends DeckManagementEvent {
  final String deckId;
  final String packId;

  const MoveDeckToPack({
    required this.deckId,
    required this.packId,
  });

  @override
  List<Object?> get props => [deckId, packId];
}

class RemoveDeckFromPack extends DeckManagementEvent {
  final String deckId;

  const RemoveDeckFromPack(this.deckId);

  @override
  List<Object?> get props => [deckId];
}

