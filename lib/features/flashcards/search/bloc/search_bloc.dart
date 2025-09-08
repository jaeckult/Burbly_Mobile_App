import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/search_service.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchService _searchService;

  SearchBloc({
    required SearchService searchService,
  })  : _searchService = searchService,
        super(const SearchState()) {
    on<SearchFlashcards>(_onSearchFlashcards);
    on<SearchNotes>(_onSearchNotes);
    on<SearchDecks>(_onSearchDecks);
    on<ClearSearch>(_onClearSearch);
    on<SetSearchQuery>(_onSetSearchQuery);
    on<SetSearchType>(_onSetSearchType);
  }

  Future<void> _onSearchFlashcards(SearchFlashcards event, Emitter<SearchState> emit) async {
    if (event.query.isEmpty) {
      emit(state.copyWith(
        flashcardResults: [],
        hasSearched: false,
      ));
      return;
    }

    emit(state.copyWith(status: SearchStatus.loading));
    try {
      final results = await _searchService.searchFlashcardsInDeck(
        event.deckId ?? '',
        event.query,
      );
      
      emit(state.copyWith(
        status: SearchStatus.success,
        flashcardResults: results,
        hasSearched: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SearchStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSearchNotes(SearchNotes event, Emitter<SearchState> emit) async {
    if (event.query.isEmpty) {
      emit(state.copyWith(
        noteResults: [],
        hasSearched: false,
      ));
      return;
    }

    emit(state.copyWith(status: SearchStatus.loading));
    try {
      final results = await _searchService.searchNotesInDeck(
        event.deckId ?? '',
        event.query,
      );
      
      emit(state.copyWith(
        status: SearchStatus.success,
        noteResults: results,
        hasSearched: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SearchStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSearchDecks(SearchDecks event, Emitter<SearchState> emit) async {
    if (event.query.isEmpty) {
      emit(state.copyWith(
        deckResults: [],
        hasSearched: false,
      ));
      return;
    }

    emit(state.copyWith(status: SearchStatus.loading));
    try {
      final results = await _searchService.searchDecks(event.query);
      
      emit(state.copyWith(
        status: SearchStatus.success,
        deckResults: results,
        hasSearched: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SearchStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onClearSearch(ClearSearch event, Emitter<SearchState> emit) async {
    emit(const SearchState());
  }

  void _onSetSearchQuery(SetSearchQuery event, Emitter<SearchState> emit) {
    emit(state.copyWith(query: event.query));
  }

  void _onSetSearchType(SetSearchType event, Emitter<SearchState> emit) {
    emit(state.copyWith(searchType: event.searchType));
  }
}

