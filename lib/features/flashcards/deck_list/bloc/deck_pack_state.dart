import 'package:equatable/equatable.dart';
import '../../../../core/models/deck.dart';
import '../../../../core/models/deck_pack.dart';

/// States for DeckPackBloc
abstract class DeckPackState extends Equatable {
  const DeckPackState();

  @override
  List<Object?> get props => [];
}

class DeckPackInitial extends DeckPackState {
  const DeckPackInitial();
}

class DeckPackLoading extends DeckPackState {
  const DeckPackLoading();
}

class DeckPackLoaded extends DeckPackState {
  final List<DeckPack> deckPacks;
  final Map<String, List<Deck>> decksInPacks;
  final Set<String> expandedPackIds;

  const DeckPackLoaded({
    required this.deckPacks,
    required this.decksInPacks,
    this.expandedPackIds = const {},
  });

  @override
  List<Object?> get props => [deckPacks, decksInPacks, expandedPackIds];

  DeckPackLoaded copyWith({
    List<DeckPack>? deckPacks,
    Map<String, List<Deck>>? decksInPacks,
    Set<String>? expandedPackIds,
  }) {
    return DeckPackLoaded(
      deckPacks: deckPacks ?? this.deckPacks,
      decksInPacks: decksInPacks ?? this.decksInPacks,
      expandedPackIds: expandedPackIds ?? this.expandedPackIds,
    );
  }
}

class DeckPackError extends DeckPackState {
  final String message;

  const DeckPackError(this.message);

  @override
  List<Object?> get props => [message];
}
