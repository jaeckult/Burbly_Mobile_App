import 'package:equatable/equatable.dart';

abstract class TrashEvent extends Equatable {
  const TrashEvent();

  @override
  List<Object?> get props => [];
}

class LoadTrash extends TrashEvent {
  const LoadTrash();
}

class RefreshTrash extends TrashEvent {
  const RefreshTrash();
}

class RestoreDeck extends TrashEvent {
  final String deckId;
  const RestoreDeck(this.deckId);
  @override
  List<Object?> get props => [deckId];
}

class RestoreFlashcard extends TrashEvent {
  final String flashcardId;
  const RestoreFlashcard(this.flashcardId);
  @override
  List<Object?> get props => [flashcardId];
}

class RestoreNote extends TrashEvent {
  final String noteId;
  const RestoreNote(this.noteId);
  @override
  List<Object?> get props => [noteId];
}

class DeleteDeckForever extends TrashEvent {
  final String deckId;
  const DeleteDeckForever(this.deckId);
  @override
  List<Object?> get props => [deckId];
}

class DeleteFlashcardForever extends TrashEvent {
  final String flashcardId;
  const DeleteFlashcardForever(this.flashcardId);
  @override
  List<Object?> get props => [flashcardId];
}

class DeleteNoteForever extends TrashEvent {
  final String noteId;
  const DeleteNoteForever(this.noteId);
  @override
  List<Object?> get props => [noteId];
}

class EmptyTrash extends TrashEvent {
  const EmptyTrash();
}
