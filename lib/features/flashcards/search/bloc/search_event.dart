import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchFlashcards extends SearchEvent {
  final String query;
  final String? deckId;

  const SearchFlashcards({
    required this.query,
    this.deckId,
  });

  @override
  List<Object?> get props => [query, deckId];
}

class SearchNotes extends SearchEvent {
  final String query;
  final String? deckId;

  const SearchNotes({
    required this.query,
    this.deckId,
  });

  @override
  List<Object?> get props => [query, deckId];
}

class SearchDecks extends SearchEvent {
  final String query;

  const SearchDecks(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearch extends SearchEvent {
  const ClearSearch();
}

class SetSearchQuery extends SearchEvent {
  final String query;

  const SetSearchQuery(this.query);

  @override
  List<Object?> get props => [query];
}

class SetSearchType extends SearchEvent {
  final SearchType searchType;

  const SetSearchType(this.searchType);

  @override
  List<Object?> get props => [searchType];
}

enum SearchType {
  all,
  flashcards,
  notes,
  decks,
}

