import '../../../../core/core.dart';

class NotesService {
  final DataService _dataService = DataService();

  Future<List<Note>> getNotes() async {
    return await _dataService.getNotes();
  }

  Future<Note?> createNote({
    required String title,
    required String content,
    String? deckId,
  }) async {
    return await _dataService.createNote(title, content, linkedDeckId: deckId);
  }

  Future<void> updateNote(Note note) async {
    await _dataService.updateNote(note);
  }

  Future<void> deleteNote(String noteId) async {
    await _dataService.deleteNote(noteId);
  }

  Future<Note?> getNote(String noteId) async {
    final notes = await _dataService.getNotes();
    try {
      return notes.firstWhere((note) => note.id == noteId);
    } catch (e) {
      return null;
    }
  }

  Future<List<Note>> getNotesForDeck(String deckId) async {
    final allNotes = await getNotes();
    return allNotes.where((note) => note.linkedDeckId == deckId).toList();
  }

  Future<List<Note>> searchNotes(String query) async {
    final allNotes = await getNotes();
    final lowercaseQuery = query.toLowerCase();
    
    return allNotes.where((note) {
      return note.title.toLowerCase().contains(lowercaseQuery) ||
             note.content.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  Future<void> duplicateNote(String noteId) async {
    final note = await getNote(noteId);
    if (note != null) {
      await createNote(
        title: '${note.title} (Copy)',
        content: note.content,
        deckId: note.linkedDeckId,
      );
    }
  }

  Future<void> moveNoteToDeck(String noteId, String deckId) async {
    final note = await getNote(noteId);
    if (note != null) {
      final updatedNote = note.copyWith(linkedDeckId: deckId);
      await updateNote(updatedNote);
    }
  }
}
