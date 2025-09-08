import 'package:equatable/equatable.dart';
import '../../../../core/models/note.dart';

abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotes extends NotesEvent {
  const LoadNotes();
}

class LoadNotesForDeck extends NotesEvent {
  final String deckId;

  const LoadNotesForDeck(this.deckId);

  @override
  List<Object?> get props => [deckId];
}

class CreateNote extends NotesEvent {
  final String title;
  final String content;
  final String? linkedDeckId;

  const CreateNote({
    required this.title,
    required this.content,
    this.linkedDeckId,
  });

  @override
  List<Object?> get props => [title, content, linkedDeckId];
}

class UpdateNote extends NotesEvent {
  final Note note;

  const UpdateNote(this.note);

  @override
  List<Object?> get props => [note];
}

class DeleteNote extends NotesEvent {
  final String noteId;

  const DeleteNote(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

class CopyNote extends NotesEvent {
  final String noteId;
  final String? newTitle;

  const CopyNote({
    required this.noteId,
    this.newTitle,
  });

  @override
  List<Object?> get props => [noteId, newTitle];
}

class MoveNoteToDeck extends NotesEvent {
  final String noteId;
  final String deckId;

  const MoveNoteToDeck({
    required this.noteId,
    required this.deckId,
  });

  @override
  List<Object?> get props => [noteId, deckId];
}

class SearchNotes extends NotesEvent {
  final String query;

  const SearchNotes(this.query);

  @override
  List<Object?> get props => [query];
}

