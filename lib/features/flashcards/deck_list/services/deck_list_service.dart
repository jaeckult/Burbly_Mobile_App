import '../../../../core/core.dart';

class DeckListService {
  final DataService _dataService = DataService();

  Future<List<DeckPack>> getDeckPacks() async {
    return await _dataService.getDeckPacks();
  }

  Future<List<Deck>> getAllDecks() async {
    return await _dataService.getDecks();
  }

  Future<Map<String, List<Deck>>> getDecksGroupedByPack() async {
    final deckPacks = await getDeckPacks();
    final allDecks = await getAllDecks();
    
    final decksInPacks = <String, List<Deck>>{};
    for (final deckPack in deckPacks) {
      decksInPacks[deckPack.id] = allDecks
          .where((deck) => deck.packId == deckPack.id)
          .toList();
    }
    
    return decksInPacks;
  }

  Future<List<Deck>> getDecksForPack(String packId) async {
    final allDecks = await getAllDecks();
    return allDecks.where((deck) => deck.packId == packId).toList();
  }

  Future<DeckPack> createDeckPack(String name, String description, {String? coverColor}) async {
    return await _dataService.createDeckPack(name, description, coverColor: coverColor);
  }

  Future<void> updateDeckPack(DeckPack deckPack) async {
    await _dataService.updateDeckPack(deckPack);
  }

  Future<void> deleteDeckPack(String packId) async {
    await _dataService.deleteDeckPack(packId);
  }

  Future<Deck> createDeck(String name, String description, {String? coverColor, String? packId}) async {
    final deck = await _dataService.createDeck(name, description, coverColor: coverColor);
    
    // If packId is provided, update the deck with packId
    if (packId != null) {
      final updatedDeck = deck.copyWith(packId: packId);
      await _dataService.updateDeck(updatedDeck);
      return updatedDeck;
    }
    
    return deck;
  }

  Future<void> deleteDeck(String deckId) async {
    await _dataService.deleteDeck(deckId);
  }

  Future<String?> getDeckPackName(String packId) async {
    return await _dataService.getDeckPackName(packId);
  }

  Future<bool> isGuestMode() async {
    return await _dataService.isGuestMode();
  }

  Future<void> initialize() async {
    if (!_dataService.isInitialized) {
      await _dataService.initialize();
    }
  }

  Future<void> backupToFirestore() async {
    await _dataService.backupToFirestore();
  }

  Future<void> loadDataFromFirestore() async {
    await _dataService.loadDataFromFirestore();
  }

  Future<void> clearAllLocalData() async {
    await _dataService.clearAllLocalData();
  }
}
