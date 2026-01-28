import '../../../../core/core.dart';

class TrashService {
  final DataService _dataService = DataService();

  Future<List<Deck>> getDeletedDecks() async {
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
    final item = trashItems.firstWhere((t) => t.itemType == 'deck' && t.originalId == deckId);
    await _dataService.restoreTrashItem(item.id);
  }

  Future<void> restoreFlashcard(String flashcardId) async {
    final trashItems = await _dataService.getTrashItems();
    final item = trashItems.firstWhere((t) => t.itemType == 'flashcard' && t.originalId == flashcardId);
    await _dataService.restoreTrashItem(item.id);
  }

  Future<void> restoreNote(String noteId) async {
    final trashItems = await _dataService.getTrashItems();
    final item = trashItems.firstWhere((t) => t.itemType == 'note' && t.originalId == noteId);
    await _dataService.restoreTrashItem(item.id);
  }

  Future<void> permanentlyDeleteDeck(String deckId) async {
    final trashItems = await _dataService.getTrashItems();
    final item = trashItems.firstWhere((t) => t.itemType == 'deck' && t.originalId == deckId);
    await _dataService.deleteTrashItemForever(item.id);
  }

  Future<void> permanentlyDeleteFlashcard(String flashcardId) async {
    final trashItems = await _dataService.getTrashItems();
    final item = trashItems.firstWhere((t) => t.itemType == 'flashcard' && t.originalId == flashcardId);
    await _dataService.deleteTrashItemForever(item.id);
  }

  Future<void> permanentlyDeleteNote(String noteId) async {
    final trashItems = await _dataService.getTrashItems();
    final item = trashItems.firstWhere((t) => t.itemType == 'note' && t.originalId == noteId);
    await _dataService.deleteTrashItemForever(item.id);
  }

  Future<void> emptyTrash() async {
    final trashItems = await _dataService.getTrashItems();
    for (final item in trashItems) {
      await _dataService.deleteTrashItemForever(item.id);
    }
  }

  Future<Map<String, int>> getTrashCounts() async {
    final trashItems = await _dataService.getTrashItems();
    return {
      'decks': trashItems.where((t) => t.itemType == 'deck').length,
      'flashcards': trashItems.where((t) => t.itemType == 'flashcard').length,
      'notes': trashItems.where((t) => t.itemType == 'note').length,
      'total': trashItems.length,
    };
  }
}
