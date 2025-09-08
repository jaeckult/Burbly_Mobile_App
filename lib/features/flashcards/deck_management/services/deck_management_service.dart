import '../../../../core/core.dart';

class DeckManagementService {
  final DataService _dataService = DataService();

  Future<List<Deck>> getDecks() async {
    return await _dataService.getDecks();
  }

  Future<List<DeckPack>> getDeckPacks() async {
    return await _dataService.getDeckPacks();
  }

  Future<Deck?> createDeck({
    required String name,
    required String description,
    String? packId,
  }) async {
    return await _dataService.createDeck(name, description);
  }

  Future<DeckPack?> createDeckPack({
    required String name,
    required String description,
  }) async {
    return await _dataService.createDeckPack(name, description);
  }

  Future<Flashcard?> createFlashcard({
    required String deckId,
    required String question,
    required String answer,
    String? extendedDescription,
    int difficulty = 3,
  }) async {
    return await _dataService.createFlashcard(
      deckId,
      question,
      answer,
      extendedDescription: extendedDescription,
      difficulty: difficulty,
    );
  }

  Future<void> updateDeck(Deck deck) async {
    await _dataService.updateDeck(deck);
  }

  Future<void> updateDeckPack(DeckPack deckPack) async {
    await _dataService.updateDeckPack(deckPack);
  }

  Future<void> updateFlashcard(Flashcard flashcard) async {
    await _dataService.updateFlashcard(flashcard);
  }

  Future<void> deleteDeck(String deckId) async {
    await _dataService.deleteDeck(deckId);
  }

  Future<void> deleteDeckPack(String packId) async {
    await _dataService.deleteDeckPack(packId);
  }

  Future<void> deleteFlashcard(String flashcardId) async {
    await _dataService.deleteFlashcard(flashcardId);
  }

  Future<List<Flashcard>> getFlashcards(String deckId) async {
    return await _dataService.getFlashcardsForDeck(deckId);
  }

  Future<Deck?> getDeck(String deckId) async {
    return await _dataService.getDeck(deckId);
  }

  Future<DeckPack?> getDeckPack(String packId) async {
    final packs = await _dataService.getDeckPacks();
    try {
      return packs.firstWhere((pack) => pack.id == packId);
    } catch (e) {
      return null;
    }
  }

  Future<void> moveDeckToPack(String deckId, String packId) async {
    final deck = await getDeck(deckId);
    if (deck != null) {
      final updatedDeck = deck.copyWith(packId: packId);
      await updateDeck(updatedDeck);
    }
  }

  Future<void> duplicateDeck(String deckId) async {
    final deck = await getDeck(deckId);
    if (deck != null) {
      final flashcards = await getFlashcards(deckId);
      
      // Create new deck with similar name
      final newDeck = await createDeck(
        name: '${deck.name} (Copy)',
        description: deck.description,
        packId: deck.packId,
      );

      if (newDeck != null) {
        // Copy all flashcards
        for (final flashcard in flashcards) {
          await createFlashcard(
            deckId: newDeck.id,
            question: flashcard.question,
            answer: flashcard.answer,
            extendedDescription: flashcard.extendedDescription,
            // Note: Flashcard model doesn't have difficulty field, using default
          );
        }
      }
    }
  }
}
