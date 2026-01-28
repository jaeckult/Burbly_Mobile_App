import '../repositories/deck_repository.dart';
import '../repositories/flashcard_repository.dart';
import '../repositories/note_repository.dart';

/// Service for performing unified search across different data sources.
class SearchService {
  final DeckRepository _deckRepository;
  final FlashcardRepository _flashcardRepository;
  final NoteRepository _noteRepository;

  SearchService({
    required DeckRepository deckRepository,
    required FlashcardRepository flashcardRepository,
    required NoteRepository noteRepository,
  })  : _deckRepository = deckRepository,
        _flashcardRepository = flashcardRepository,
        _noteRepository = noteRepository;

  /// Search across decks, flashcards, and notes
  Future<Map<String, List<dynamic>>> searchAll(String query) async {
    final lowercaseQuery = query.toLowerCase();
    
    final decks = await _deckRepository.getAll();
    final matchingDecks = decks.where((d) => 
      d.name.toLowerCase().contains(lowercaseQuery) || 
      d.description.toLowerCase().contains(lowercaseQuery)
    ).toList();

    final cards = await _flashcardRepository.getAll();
    final matchingCards = cards.where((c) => 
      c.question.toLowerCase().contains(lowercaseQuery) || 
      c.answer.toLowerCase().contains(lowercaseQuery)
    ).toList();

    final notes = await _noteRepository.getAll();
    final matchingNotes = notes.where((n) {
      final inTitle = n.title.toLowerCase().contains(lowercaseQuery);
      final inContent = n.content.toLowerCase().contains(lowercaseQuery);
      final inTags = n.tags.any((t) => t.toLowerCase().contains(lowercaseQuery));
      return inTitle || inContent || inTags;
    }).toList();

    return {
      'decks': matchingDecks,
      'flashcards': matchingCards,
      'notes': matchingNotes,
    };
  }
}
