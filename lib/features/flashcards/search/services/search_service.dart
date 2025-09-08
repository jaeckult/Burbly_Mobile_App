import '../../../../core/core.dart';

class SearchService {
  final DataService _dataService = DataService();

  Future<List<Flashcard>> searchFlashcards(String query) async {
    final allFlashcards = await _dataService.getAllFlashcards();
    final lowercaseQuery = query.toLowerCase();
    
    return allFlashcards.where((flashcard) {
      return flashcard.question.toLowerCase().contains(lowercaseQuery) ||
             flashcard.answer.toLowerCase().contains(lowercaseQuery) ||
             (flashcard.extendedDescription?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  Future<List<Deck>> searchDecks(String query) async {
    final allDecks = await _dataService.getDecks();
    final lowercaseQuery = query.toLowerCase();
    
    return allDecks.where((deck) {
      return deck.name.toLowerCase().contains(lowercaseQuery) ||
             deck.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  Future<List<Note>> searchNotes(String query) async {
    final allNotes = await _dataService.getNotes();
    final lowercaseQuery = query.toLowerCase();
    
    return allNotes.where((note) {
      return note.title.toLowerCase().contains(lowercaseQuery) ||
             note.content.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  Future<List<DeckPack>> searchDeckPacks(String query) async {
    final allPacks = await _dataService.getDeckPacks();
    final lowercaseQuery = query.toLowerCase();
    
    return allPacks.where((pack) {
      return pack.name.toLowerCase().contains(lowercaseQuery) ||
             pack.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  Future<Map<String, List<dynamic>>> searchAll(String query) async {
    final results = await Future.wait([
      searchFlashcards(query),
      searchDecks(query),
      searchNotes(query),
      searchDeckPacks(query),
    ]);

    return {
      'flashcards': results[0],
      'decks': results[1],
      'notes': results[2],
      'deckPacks': results[3],
    };
  }

  Future<List<Flashcard>> searchFlashcardsInDeck(String deckId, String query) async {
    final flashcards = await _dataService.getFlashcardsForDeck(deckId);
    final lowercaseQuery = query.toLowerCase();
    
    return flashcards.where((flashcard) {
      return flashcard.question.toLowerCase().contains(lowercaseQuery) ||
             flashcard.answer.toLowerCase().contains(lowercaseQuery) ||
             (flashcard.extendedDescription?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  Future<List<Note>> searchNotesInDeck(String deckId, String query) async {
    final notes = await _dataService.getNotes();
    final lowercaseQuery = query.toLowerCase();
    
    return notes.where((note) {
      return note.linkedDeckId == deckId && (
        note.title.toLowerCase().contains(lowercaseQuery) ||
        note.content.toLowerCase().contains(lowercaseQuery)
      );
    }).toList();
  }
}
