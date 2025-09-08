import '../../../../core/core.dart';

class TrashService {
  final DataService _dataService = DataService();

  Future<List<Deck>> getDeletedDecks() async {
    // Use trash box to determine deleted items
    final trashItems = await _dataService.getTrashItems();
    final deckIds = trashItems.where((item) => item.itemType == 'deck').map((item) => item.originalId).toList();
    final allDecks = await _dataService.getDecks();
    return allDecks.where((deck) => deckIds.contains(deck.id)).toList();
  }

  Future<List<Flashcard>> getDeletedFlashcards() async {
    final trashItems = await _dataService.getTrashItems();
    final flashcardIds = trashItems.where((item) => item.itemType == 'flashcard').map((item) => item.originalId).toList();
    final allFlashcards = await _dataService.getAllFlashcards();
    return allFlashcards.where((flashcard) => flashcardIds.contains(flashcard.id)).toList();
  }

  Future<List<Note>> getDeletedNotes() async {
    final trashItems = await _dataService.getTrashItems();
    final noteIds = trashItems.where((item) => item.itemType == 'note').map((item) => item.originalId).toList();
    final allNotes = await _dataService.getNotes();
    return allNotes.where((note) => noteIds.contains(note.id)).toList();
  }

  Future<void> restoreDeck(String deckId) async {
    final trashItems = await _dataService.getTrashItems();
    final item = trashItems.firstWhere((t) => t.itemType == 'deck' && t.originalId == deckId, orElse: () => throw Exception('Trash item not found'));
    await _dataService.restoreTrashItem(item);
  }

  Future<void> restoreFlashcard(String flashcardId) async {
    final trashItems = await _dataService.getTrashItems();
    final item = trashItems.firstWhere((t) => t.itemType == 'flashcard' && t.originalId == flashcardId, orElse: () => throw Exception('Trash item not found'));
    await _dataService.restoreTrashItem(item);
  }

  Future<void> restoreNote(String noteId) async {
    final trashItems = await _dataService.getTrashItems();
    final item = trashItems.firstWhere((t) => t.itemType == 'note' && t.originalId == noteId, orElse: () => throw Exception('Trash item not found'));
    await _dataService.restoreTrashItem(item);
  }

  Future<void> permanentlyDeleteDeck(String deckId) async {
    final trashItems = await _dataService.getTrashItems();
    final item = trashItems.firstWhere((t) => t.itemType == 'deck' && t.originalId == deckId, orElse: () => throw Exception('Trash item not found'));
    await _dataService.deleteDeck(deckId);
    await _dataService.deleteTrashItemForever(item.id);
  }

  Future<void> permanentlyDeleteFlashcard(String flashcardId) async {
    final trashItems = await _dataService.getTrashItems();
    final item = trashItems.firstWhere((t) => t.itemType == 'flashcard' && t.originalId == flashcardId, orElse: () => throw Exception('Trash item not found'));
    await _dataService.deleteFlashcard(flashcardId);
    await _dataService.deleteTrashItemForever(item.id);
  }

  Future<void> permanentlyDeleteNote(String noteId) async {
    final trashItems = await _dataService.getTrashItems();
    final item = trashItems.firstWhere((t) => t.itemType == 'note' && t.originalId == noteId, orElse: () => throw Exception('Trash item not found'));
    await _dataService.deleteNote(noteId);
    await _dataService.deleteTrashItemForever(item.id);
  }

  Future<void> emptyTrash() async {
    final deletedDecks = await getDeletedDecks();
    final deletedFlashcards = await getDeletedFlashcards();
    final deletedNotes = await getDeletedNotes();

    // Permanently delete all items in trash
    for (final deck in deletedDecks) {
      await permanentlyDeleteDeck(deck.id);
    }

    for (final flashcard in deletedFlashcards) {
      await permanentlyDeleteFlashcard(flashcard.id);
    }

    for (final note in deletedNotes) {
      await permanentlyDeleteNote(note.id);
    }
  }

  Future<Map<String, int>> getTrashCounts() async {
    final deletedDecks = await getDeletedDecks();
    final deletedFlashcards = await getDeletedFlashcards();
    final deletedNotes = await getDeletedNotes();

    return {
      'decks': deletedDecks.length,
      'flashcards': deletedFlashcards.length,
      'notes': deletedNotes.length,
      'total': deletedDecks.length + deletedFlashcards.length + deletedNotes.length,
    };
  }
}
