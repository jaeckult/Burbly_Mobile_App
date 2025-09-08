import '../../../../core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeService {
  final DataService _dataService = DataService();

  Future<List<Deck>> getDecks() async {
    return await _dataService.getDecks();
  }

  Future<List<DeckPack>> getDeckPacks() async {
    return await _dataService.getDeckPacks();
  }

  Future<Map<String, dynamic>> getOverallStats() async {
    return await _dataService.getOverallStats();
  }

  Future<List<Flashcard>> getDueCards() async {
    final allFlashcards = await _dataService.getAllFlashcards();
    final now = DateTime.now();
    
    return allFlashcards.where((card) {
      if (card.nextReview == null) return true;
      return card.nextReview!.isBefore(now) || card.nextReview!.isAtSameMomentAs(now);
    }).toList();
  }

  Future<List<StudySession>> getRecentStudySessions({int limit = 5}) async {
    final allSessions = await _dataService.getAllStudySessions();
    allSessions.sort((a, b) => b.date.compareTo(a.date));
    return allSessions.take(limit).toList();
  }

  Future<List<Deck>> getRecentlyStudiedDecks({int limit = 5}) async {
    final recentSessions = await getRecentStudySessions(limit: limit);
    final deckIds = recentSessions.map((session) => session.deckId).toSet();
    final allDecks = await getDecks();
    
    return allDecks.where((deck) => deckIds.contains(deck.id)).toList();
  }

  Future<List<Deck>> getFavoriteDecks() async {
    final allDecks = await getDecks();
    // Note: Deck model doesn't have isFavorite field, returning all decks for now
    return allDecks;
  }

  Future<void> toggleDeckFavorite(String deckId) async {
    // Note: Deck model doesn't have isFavorite field, this is a placeholder
    // Implementation would depend on how favorites are stored
  }

  Future<void> syncData() async {
    await _dataService.initialize();
    await _dataService.loadDataFromFirestore();
  }

  Future<bool> isGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_guest_mode') ?? false;
  }

  Future<void> setGuestMode(bool isGuest) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_guest_mode', isGuest);
  }
}
