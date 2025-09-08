import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/note.dart';
import '../services/notes_service.dart';
import 'notes_event.dart';
import 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NotesService _notesService;

  NotesBloc({
    required NotesService notesService,
  })  : _notesService = notesService,
        super(const NotesState()) {
    on<LoadNotes>(_onLoadNotes);
    on<LoadNotesForDeck>(_onLoadNotesForDeck);
    on<CreateNote>(_onCreateNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
    on<CopyNote>(_onCopyNote);
    on<MoveNoteToDeck>(_onMoveNoteToDeck);
    on<SearchNotes>(_onSearchNotes);
  }

  Future<void> _onLoadNotes(LoadNotes event, Emitter<NotesState> emit) async {
    emit(state.copyWith(status: NotesStatus.loading));
    try {
      final notes = await _notesService.getNotes();
      emit(state.copyWith(
        status: NotesStatus.success,
        notes: notes,
        filteredNotes: notes,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotesStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadNotesForDeck(LoadNotesForDeck event, Emitter<NotesState> emit) async {
    emit(state.copyWith(status: NotesStatus.loading));
    try {
      final notes = await _notesService.getNotesForDeck(event.deckId);
      emit(state.copyWith(
        status: NotesStatus.success,
        notes: notes,
        filteredNotes: notes,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotesStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCreateNote(CreateNote event, Emitter<NotesState> emit) async {
    emit(state.copyWith(isCreating: true));
    try {
      final note = await _notesService.createNote(
        title: event.title,
        content: event.content,
        deckId: event.linkedDeckId,
      );
      if (note == null) {
        emit(state.copyWith(isCreating: false));
        return;
      }
      
      final updatedNotes = List<Note>.from(state.notes)..add(note);
      emit(state.copyWith(
        isCreating: false,
        notes: updatedNotes,
        filteredNotes: updatedNotes,
      ));
    } catch (e) {
      emit(state.copyWith(
        isCreating: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateNote(UpdateNote event, Emitter<NotesState> emit) async {
    emit(state.copyWith(isUpdating: true));
    try {
      await _notesService.updateNote(event.note);
      
      final updatedNotes = state.notes.map((note) {
        return note.id == event.note.id ? event.note : note;
      }).toList();
      
      emit(state.copyWith(
        isUpdating: false,
        notes: updatedNotes,
        filteredNotes: updatedNotes,
      ));
    } catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteNote(DeleteNote event, Emitter<NotesState> emit) async {
    emit(state.copyWith(isDeleting: true));
    try {
      await _notesService.deleteNote(event.noteId);
      
      final updatedNotes = state.notes.where((note) => note.id != event.noteId).toList();
      emit(state.copyWith(
        isDeleting: false,
        notes: updatedNotes,
        filteredNotes: updatedNotes,
      ));
    } catch (e) {
      emit(state.copyWith(
        isDeleting: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCopyNote(CopyNote event, Emitter<NotesState> emit) async {
    try {
      await _notesService.duplicateNote(event.noteId);
      final updatedNotes = await _notesService.getNotes();
      
      emit(state.copyWith(
        notes: updatedNotes,
        filteredNotes: updatedNotes,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onMoveNoteToDeck(MoveNoteToDeck event, Emitter<NotesState> emit) async {
    try {
      await _notesService.moveNoteToDeck(event.noteId, event.deckId);
      
      final updatedNotes = state.notes.map((note) {
        if (note.id == event.noteId) {
          return note.copyWith(linkedDeckId: event.deckId);
        }
        return note;
      }).toList();
      
      emit(state.copyWith(
        notes: updatedNotes,
        filteredNotes: updatedNotes,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onSearchNotes(SearchNotes event, Emitter<NotesState> emit) async {
    if (event.query.isEmpty) {
      emit(state.copyWith(
        searchQuery: '',
        filteredNotes: state.notes,
      ));
      return;
    }

    final filteredNotes = state.notes.where((note) {
      return note.title.toLowerCase().contains(event.query.toLowerCase()) ||
             note.content.toLowerCase().contains(event.query.toLowerCase());
    }).toList();

    emit(state.copyWith(
      searchQuery: event.query,
      filteredNotes: filteredNotes,
    ));
  }
}

