import 'package:equatable/equatable.dart';
import '../../../../core/models/flashcard.dart';
import '../../../../core/models/note.dart';
import '../../../../core/models/deck.dart';
import 'search_event.dart';

enum SearchStatus {
  initial,
  loading,
  success,
  failure,
}

class SearchState extends Equatable {
  final SearchStatus status;
  final String query;
  final SearchType searchType;
  final List<Flashcard> flashcardResults;
  final List<Note> noteResults;
  final List<Deck> deckResults;
  final String? errorMessage;
  final bool hasSearched;

  const SearchState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.searchType = SearchType.all,
    this.flashcardResults = const [],
    this.noteResults = const [],
    this.deckResults = const [],
    this.errorMessage,
    this.hasSearched = false,
  });

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    SearchType? searchType,
    List<Flashcard>? flashcardResults,
    List<Note>? noteResults,
    List<Deck>? deckResults,
    String? errorMessage,
    bool? hasSearched,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      searchType: searchType ?? this.searchType,
      flashcardResults: flashcardResults ?? this.flashcardResults,
      noteResults: noteResults ?? this.noteResults,
      deckResults: deckResults ?? this.deckResults,
      errorMessage: errorMessage ?? this.errorMessage,
      hasSearched: hasSearched ?? this.hasSearched,
    );
  }

  @override
  List<Object?> get props => [
        status,
        query,
        searchType,
        flashcardResults,
        noteResults,
        deckResults,
        errorMessage,
        hasSearched,
      ];
}

