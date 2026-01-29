import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trash_item.dart';
import '../models/deck.dart';
import '../models/flashcard.dart';
import '../models/deck_pack.dart';
import '../models/note.dart';
import '../models/study_session.dart';
import '../repositories/deck_repository.dart';
import '../repositories/flashcard_repository.dart';
import '../repositories/deck_pack_repository.dart';
import '../repositories/note_repository.dart';
import '../repositories/study_session_repository.dart';
import '../repositories/trash_repository.dart';
import '../services/local_storage_service.dart';
import '../services/sync_service.dart';
import '../services/stats_service.dart';
import '../services/search_service.dart';
import '../services/trash_service.dart';
import '../di/service_locator.dart';

/// Facade service that provides a unified entry point for data operations.
/// This maintains backward compatibility while delegating to specialized repositories and services.
class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  // Lazy getters for dependencies from locator
  LocalStorageService get _storage => locator<LocalStorageService>();
  DeckRepository get _deckRepo => locator<DeckRepository>();
  FlashcardRepository get _flashcardRepo => locator<FlashcardRepository>();
  DeckPackRepository get _deckPackRepo => locator<DeckPackRepository>();
  NoteRepository get _noteRepo => locator<NoteRepository>();
  StudySessionRepository get _sessionRepo => locator<StudySessionRepository>();
  SyncService get _syncService => locator<SyncService>();
  
  // Re-creating services internally if not in locator, but better to put them in locator
  // For now, I'll use locator for everything I've registered
  
  bool get isInitialized => _storage.isInitialized;
  bool get areBoxesAccessible => _storage.areBoxesAccessible;
  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> initialize() => _storage.initialize();
  Future<void> reinitialize() => _storage.reinitialize();
  Future<void> clearAllLocalData() => _storage.clearAllData();
  
  Future<Map<String, int>> getDataCounts() async => _storage.getDataCounts();

  // DECK OPERATIONS
  Future<Deck> createDeck(String name, String description, {String? coverColor}) =>
      _deckRepo.create(name: name, description: description, coverColor: coverColor);
  
  Future<List<Deck>> getDecks() => _deckRepo.getAll();
  Future<Deck?> getDeck(String id) => _deckRepo.getById(id);
  
  Future<void> updateDeck(Deck deck) async {
    final timestamp = DateTime.now().toIso8601String();
    print('[$timestamp] DataService: SAVE Deck "${deck.name}" (ID: ${deck.id})');
    print('[$timestamp] DataService:   Schedule: ${deck.scheduledReviewTime}');
    print('[$timestamp] DataService:   Enabled: ${deck.scheduledReviewEnabled}');
    
    await _deckRepo.update(deck);
    
    // Verify persistence immediately
    try {
      final saved = await _deckRepo.getById(deck.id);
      print('[$timestamp] DataService: VERIFY Saved Schedule: ${saved?.scheduledReviewTime}');
    } catch (e) {
      print('[$timestamp] DataService: VERITIFICATION FAILED: $e');
    }
  }

  Future<void> deleteDeck(String id) => _deckRepo.delete(id);

  // FLASHCARD OPERATIONS
  Future<Flashcard> createFlashcard(String deckId, String question, String answer, {int difficulty = 3, String? extendedDescription}) =>
      _flashcardRepo.create(deckId: deckId, question: question, answer: answer, extendedDescription: extendedDescription);
  
  Future<List<Flashcard>> getFlashcardsForDeck(String deckId) => _flashcardRepo.getByDeckId(deckId);
  Future<List<Flashcard>> getAllFlashcards() => _flashcardRepo.getAll();
  Future<void> updateFlashcard(Flashcard card) => _flashcardRepo.update(card);
  Future<void> deleteFlashcard(String id) => _flashcardRepo.delete(id);
  
  // SPACED REPETITION
  Future<void> updateFlashcardWithReview(Flashcard card, int quality) => _flashcardRepo.updateWithReview(card, quality);
  Future<List<Flashcard>> getDueFlashcards(String deckId) => _flashcardRepo.getDueForReview(deckId);
  Future<List<Flashcard>> getFlashcardsDueInDays(String deckId, int days) => _flashcardRepo.getDueInDays(deckId, days);
  Future<List<Flashcard>> getLearningCards(String deckId) => _flashcardRepo.getLearningCards(deckId);
  Future<List<Flashcard>> getReviewCards(String deckId) => _flashcardRepo.getReviewCards(deckId);

  // DECK PACK OPERATIONS
  Future<DeckPack> createDeckPack(String name, String description, {String? coverColor}) =>
      _deckPackRepo.create(name: name, description: description, coverColor: coverColor);
  
  Future<List<DeckPack>> getDeckPacks() => _deckPackRepo.getAll();
  Future<void> updateDeckPack(DeckPack pack) => _deckPackRepo.update(pack);
  Future<void> deleteDeckPack(String id) => _deckPackRepo.delete(id);
  Future<void> addDeckToPack(String deckId, String packId) async {
    // 1. Add deck to pack (updates DeckPack)
    await _deckPackRepo.addDeckToPack(packId, deckId);
    
    // 2. Update deck with packId (updates Deck)
    final deck = await _deckRepo.getById(deckId);
    if (deck != null && deck.packId != packId) {
      final updatedDeck = deck.copyWith(
        packId: packId,
        updatedAt: DateTime.now(),
      );
      await updateDeck(updatedDeck);
    }
  }
  Future<void> removeDeckFromPack(String deckId, String packId) async {
    // 1. Remove deck from pack (updates DeckPack)
    await _deckPackRepo.removeDeckFromPack(packId, deckId);
    
    // 2. Update deck to remove packId (updates Deck)
    final deck = await _deckRepo.getById(deckId);
    if (deck != null && deck.packId == packId) {
      final updatedDeck = deck.copyWith(
        clearPackId: true,
        updatedAt: DateTime.now(),
      );
      // Note: we need to ensure copyWith handles setting null correctly
      await updateDeck(updatedDeck);
    }
  }
  Future<String?> getDeckPackName(String id) => _deckPackRepo.getNameById(id);

  // NOTE OPERATIONS
  Future<Note> createNote(String title, String content, {String? linkedCardId, String? linkedDeckId, String? linkedPackId, List<String>? tags}) =>
      _noteRepo.create(title: title, content: content, linkedCardId: linkedCardId, linkedDeckId: linkedDeckId, linkedPackId: linkedPackId, tags: tags);
  
  Future<List<Note>> getNotes() => _noteRepo.getAll();
  Future<List<Note>> getNotesForItem({String? cardId, String? deckId, String? packId}) =>
      _noteRepo.getByLink(cardId: cardId, deckId: deckId, packId: packId);
  
  Future<void> updateNote(Note note) => _noteRepo.update(note);
  Future<void> deleteNote(String id) => _noteRepo.delete(id);

  // STATS & SESSIONS
  Future<void> saveStudySession(StudySession session) => _sessionRepo.save(session);
  Future<List<StudySession>> getStudySessionsForDeck(String deckId) => _sessionRepo.getByDeckId(deckId);
  Future<List<StudySession>> getAllStudySessions() => _sessionRepo.getAll();
  Future<List<StudySession>> getStudySessionsForDays(int days) => _sessionRepo.getForLastDays(days);
  
  Future<Map<String, dynamic>> getDeckStats(String deckId) => StatsService(
    deckRepository: _deckRepo,
    sessionRepository: _sessionRepo,
  ).getDeckStats(deckId);

  Future<Map<String, dynamic>> getOverallStats() => StatsService(
    deckRepository: _deckRepo,
    sessionRepository: _sessionRepo,
  ).getOverallStats();

  // SYNC & BACKUP
  Future<void> backupToFirestore() => _syncService.backupToFirestore();
  Future<void> loadDataFromFirestore() => _syncService.loadDataFromFirestore();
  Future<Map<String, int>> getBackupStats() => getDataCounts();

  // TRASH OPERATIONS
  Future<List<TrashItem>> getTrashItems() => locator<TrashRepository>().getAll();
  Future<void> restoreTrashItem(String id) => locator<TrashService>().restore(id);
  Future<void> deleteTrashItemForever(String id) => locator<TrashRepository>().permanentDelete(id);


  // SEARCH
  Future<Map<String, dynamic>> searchAll(String query) => SearchService(
    deckRepository: _deckRepo,
    flashcardRepository: _flashcardRepo,
    noteRepository: _noteRepo,
  ).searchAll(query);

  // INTEGRITY
  Future<Map<String, dynamic>> checkDataIntegrity() => _storage.checkDataIntegrity();
  Future<bool> verifyDataPersistence() async {
    final counts = await getDataCounts();
    return counts.values.any((v) => v > 0);
  }

  // GUEST MODE
  Future<bool> isGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isGuestMode') ?? false;
  }
  
  Future<void> dispose() async => _storage.reinitialize();
}

