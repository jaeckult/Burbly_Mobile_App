import 'package:equatable/equatable.dart';
import '../../../../core/models/deck.dart';
import '../../../../core/models/deck_pack.dart';

abstract class DeckListEvent extends Equatable {
  const DeckListEvent();

  @override
  List<Object?> get props => [];
}

class LoadDeckPacks extends DeckListEvent {
  const LoadDeckPacks();
}

class RefreshDeckPacks extends DeckListEvent {
  const RefreshDeckPacks();
}

class CreateDeckPack extends DeckListEvent {
  final DeckPack deckPack;

  const CreateDeckPack(this.deckPack);

  @override
  List<Object?> get props => [deckPack];
}

class UpdateDeckPack extends DeckListEvent {
  final DeckPack deckPack;

  const UpdateDeckPack(this.deckPack);

  @override
  List<Object?> get props => [deckPack];
}

class DeleteDeckPack extends DeckListEvent {
  final String packId;

  const DeleteDeckPack(this.packId);

  @override
  List<Object?> get props => [packId];
}

class CreateDeckInPack extends DeckListEvent {
  final Deck deck;

  const CreateDeckInPack(this.deck);

  @override
  List<Object?> get props => [deck];
}

class DeleteDeckFromPack extends DeckListEvent {
  final String deckId;

  const DeleteDeckFromPack(this.deckId);

  @override
  List<Object?> get props => [deckId];
}

class TogglePackExpansion extends DeckListEvent {
  final String packId;

  const TogglePackExpansion(this.packId);

  @override
  List<Object?> get props => [packId];
}
