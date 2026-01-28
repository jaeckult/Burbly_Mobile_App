import 'package:equatable/equatable.dart';
import '../../../../core/models/deck.dart';
import '../../../../core/models/deck_pack.dart';

/// Events for DeckPackBloc
abstract class DeckPackEvent extends Equatable {
  const DeckPackEvent();

  @override
  List<Object?> get props => [];
}

class LoadDeckPacks extends DeckPackEvent {
  const LoadDeckPacks();
}

class RefreshDeckPacks extends DeckPackEvent {
  const RefreshDeckPacks();
}

class TogglePackExpansion extends DeckPackEvent {
  final String packId;

  const TogglePackExpansion(this.packId);

  @override
  List<Object?> get props => [packId];
}

class CreateDeckPack extends DeckPackEvent {
  final String name;
  final String description;
  final String? coverColor;

  const CreateDeckPack({
    required this.name,
    required this.description,
    this.coverColor,
  });

  @override
  List<Object?> get props => [name, description, coverColor];
}

class UpdateDeckPack extends DeckPackEvent {
  final DeckPack deckPack;

  const UpdateDeckPack(this.deckPack);

  @override
  List<Object?> get props => [deckPack];
}

class DeleteDeckPack extends DeckPackEvent {
  final String packId;

  const DeleteDeckPack(this.packId);

  @override
  List<Object?> get props => [packId];
}

class CreateDeck extends DeckPackEvent {
  final String packId;
  final String name;
  final String description;
  final String? coverColor;

  const CreateDeck({
    required this.packId,
    required this.name,
    required this.description,
    this.coverColor,
  });

  @override
  List<Object?> get props => [packId, name, description, coverColor];
}

class DeleteDeck extends DeckPackEvent {
  final String deckId;

  const DeleteDeck(this.deckId);

  @override
  List<Object?> get props => [deckId];
}
