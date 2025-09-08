import 'package:equatable/equatable.dart';
import '../../../../core/models/deck.dart';
import '../../../../core/models/deck_pack.dart';

enum DeckListStatus {
  initial,
  loading,
  success,
  failure,
}

class DeckListState extends Equatable {
  final DeckListStatus status;
  final List<DeckPack> deckPacks;
  final List<Deck> allDecks;
  final Map<String, List<Deck>> decksInPacks;
  final Map<String, bool> expandedPacks;
  final String? errorMessage;
  final bool isRefreshing;
  final bool isCreating;
  final bool isDeleting;

  const DeckListState({
    this.status = DeckListStatus.initial,
    this.deckPacks = const [],
    this.allDecks = const [],
    this.decksInPacks = const {},
    this.expandedPacks = const {},
    this.errorMessage,
    this.isRefreshing = false,
    this.isCreating = false,
    this.isDeleting = false,
  });

  DeckListState copyWith({
    DeckListStatus? status,
    List<DeckPack>? deckPacks,
    List<Deck>? allDecks,
    Map<String, List<Deck>>? decksInPacks,
    Map<String, bool>? expandedPacks,
    String? errorMessage,
    bool? isRefreshing,
    bool? isCreating,
    bool? isDeleting,
  }) {
    return DeckListState(
      status: status ?? this.status,
      deckPacks: deckPacks ?? this.deckPacks,
      allDecks: allDecks ?? this.allDecks,
      decksInPacks: decksInPacks ?? this.decksInPacks,
      expandedPacks: expandedPacks ?? this.expandedPacks,
      errorMessage: errorMessage ?? this.errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isCreating: isCreating ?? this.isCreating,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  @override
  List<Object?> get props => [
        status,
        deckPacks,
        allDecks,
        decksInPacks,
        expandedPacks,
        errorMessage,
        isRefreshing,
        isCreating,
        isDeleting,
      ];
}
