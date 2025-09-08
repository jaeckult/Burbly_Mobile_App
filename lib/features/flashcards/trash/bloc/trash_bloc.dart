import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/trash_service.dart';
import 'trash_event.dart';
import 'trash_state.dart';

class TrashBloc extends Bloc<TrashEvent, TrashState> {
  final TrashService _trashService;

  TrashBloc({required TrashService trashService})
      : _trashService = trashService,
        super(const TrashState()) {
    on<LoadTrash>(_onLoadTrash);
    on<RefreshTrash>(_onRefreshTrash);
    on<RestoreDeck>(_onRestoreDeck);
    on<RestoreFlashcard>(_onRestoreFlashcard);
    on<RestoreNote>(_onRestoreNote);
    on<DeleteDeckForever>(_onDeleteDeckForever);
    on<DeleteFlashcardForever>(_onDeleteFlashcardForever);
    on<DeleteNoteForever>(_onDeleteNoteForever);
    on<EmptyTrash>(_onEmptyTrash);
  }

  Future<void> _loadData(Emitter<TrashState> emit) async {
    final decks = await _trashService.getDeletedDecks();
    final cards = await _trashService.getDeletedFlashcards();
    final notes = await _trashService.getDeletedNotes();
    final counts = await _trashService.getTrashCounts();
    emit(state.copyWith(
      isLoading: false,
      deletedDecks: decks,
      deletedFlashcards: cards,
      deletedNotes: notes,
      counts: counts,
      clearError: true,
    ));
  }

  Future<void> _onLoadTrash(LoadTrash event, Emitter<TrashState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _loadData(emit);
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onRefreshTrash(RefreshTrash event, Emitter<TrashState> emit) async {
    try {
      await _loadData(emit);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onRestoreDeck(RestoreDeck event, Emitter<TrashState> emit) async {
    try {
      await _trashService.restoreDeck(event.deckId);
      await _loadData(emit);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onRestoreFlashcard(RestoreFlashcard event, Emitter<TrashState> emit) async {
    try {
      await _trashService.restoreFlashcard(event.flashcardId);
      await _loadData(emit);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onRestoreNote(RestoreNote event, Emitter<TrashState> emit) async {
    try {
      await _trashService.restoreNote(event.noteId);
      await _loadData(emit);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteDeckForever(DeleteDeckForever event, Emitter<TrashState> emit) async {
    try {
      await _trashService.permanentlyDeleteDeck(event.deckId);
      await _loadData(emit);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteFlashcardForever(DeleteFlashcardForever event, Emitter<TrashState> emit) async {
    try {
      await _trashService.permanentlyDeleteFlashcard(event.flashcardId);
      await _loadData(emit);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteNoteForever(DeleteNoteForever event, Emitter<TrashState> emit) async {
    try {
      await _trashService.permanentlyDeleteNote(event.noteId);
      await _loadData(emit);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onEmptyTrash(EmptyTrash event, Emitter<TrashState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _trashService.emptyTrash();
      await _loadData(emit);
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
