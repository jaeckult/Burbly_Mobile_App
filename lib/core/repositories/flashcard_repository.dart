import '../models/flashcard.dart';
import '../models/trash_item.dart';
import '../services/local_storage_service.dart';

/// Repository for Flashcard CRUD operations.
/// Uses LocalStorageService for persistence.
class FlashcardRepository {
  final LocalStorageService _storage;

  FlashcardRepository({LocalStorageService? storage})
      : _storage = storage ?? LocalStorageService();

  void _ensureInitialized() {
    if (!_storage.areBoxesAccessible) {
      throw Exception('Storage not initialized. Call LocalStorageService.initialize() first.');
    }
  }

  /// Save a flashcard exactly as provided (useful for sync/restore)
  Future<void> save(Flashcard flashcard) async {
    _ensureInitialized();
    await _storage.flashcardsBox.put(flashcard.id, flashcard);
  }

  /// Create a new flashcard
  Future<Flashcard> create({
    required String deckId,
    required String question,
    required String answer,
    String? extendedDescription,
    double easeFactor = 2.5,
  }) async {
    _ensureInitialized();

    final now = DateTime.now();
    final flashcard = Flashcard(
      id: now.millisecondsSinceEpoch.toString(),
      deckId: deckId,
      question: question,
      answer: answer,
      easeFactor: easeFactor,
      createdAt: now,
      updatedAt: now,
      extendedDescription: extendedDescription,
    );

    await _storage.flashcardsBox.put(flashcard.id, flashcard);
    
    // Update deck card count
    await _updateDeckCardCount(deckId, 1);

    return flashcard;
  }

  /// Get all flashcards
  Future<List<Flashcard>> getAll() async {
    _ensureInitialized();
    return _storage.flashcardsBox.values.toList();
  }

  /// Get flashcard by ID
  Future<Flashcard?> getById(String id) async {
    _ensureInitialized();
    return _storage.flashcardsBox.get(id);
  }

  /// Get flashcards for a specific deck
  Future<List<Flashcard>> getByDeckId(String deckId) async {
    _ensureInitialized();
    return _storage.flashcardsBox.values
        .where((card) => card.deckId == deckId)
        .toList();
  }

  /// Get flashcards due for review
  Future<List<Flashcard>> getDueForReview(String deckId) async {
    _ensureInitialized();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _storage.flashcardsBox.values
        .where((card) =>
            card.deckId == deckId &&
            (card.nextReview == null ||
                card.nextReview!.isBefore(today.add(const Duration(days: 1)))))
        .toList();
  }

  /// Get flashcards due in the next X days
  Future<List<Flashcard>> getDueInDays(String deckId, int days) async {
    _ensureInitialized();
    final futureDate = DateTime.now().add(Duration(days: days));

    return _storage.flashcardsBox.values
        .where((card) =>
            card.deckId == deckId &&
            card.nextReview != null &&
            card.nextReview!.isBefore(futureDate))
        .toList();
  }

  /// Get learning cards (new or failed cards with interval = 1)
  Future<List<Flashcard>> getLearningCards(String deckId) async {
    _ensureInitialized();
    return _storage.flashcardsBox.values
        .where((card) => card.deckId == deckId && card.interval == 1)
        .toList();
  }

  /// Get review cards (cards with interval > 1)
  Future<List<Flashcard>> getReviewCards(String deckId) async {
    _ensureInitialized();
    return _storage.flashcardsBox.values
        .where((card) => card.deckId == deckId && card.interval > 1)
        .toList();
  }

  /// Update a flashcard
  Future<void> update(Flashcard flashcard) async {
    _ensureInitialized();
    final updatedFlashcard = flashcard.copyWith(updatedAt: DateTime.now());
    await _storage.flashcardsBox.put(flashcard.id, updatedFlashcard);
  }

  /// Update flashcard with spaced repetition review
  Future<void> updateWithReview(Flashcard flashcard, int quality) async {
    _ensureInitialized();

    final now = DateTime.now();
    int newInterval;
    double newEaseFactor;

    // SM2 Algorithm Implementation
    if (quality >= 3) {
      // Successful recall
      if (flashcard.interval == 1) {
        newInterval = 6;
      } else {
        newInterval = (flashcard.interval * flashcard.easeFactor).round();
      }

      // Adjust ease factor based on quality
      double qualityAdjustment = quality == 3 ? -0.15 : (quality == 4 ? 0.0 : 0.1);
      newEaseFactor = flashcard.easeFactor + qualityAdjustment;
    } else {
      // Failed recall - reset to learning phase
      newInterval = 1;
      newEaseFactor = flashcard.easeFactor - 0.2;
    }

    // Clamp ease factor
    newEaseFactor = newEaseFactor.clamp(1.3, 2.5);

    final updatedFlashcard = flashcard.copyWith(
      interval: newInterval,
      easeFactor: newEaseFactor,
      nextReview: now.add(Duration(days: newInterval)),
      lastReviewed: now,
      reviewCount: flashcard.reviewCount + 1,
      updatedAt: now,
    );

    await _storage.flashcardsBox.put(flashcard.id, updatedFlashcard);
  }

  /// Delete a flashcard (moves to trash)
  Future<void> delete(String id) async {
    _ensureInitialized();

    final flashcard = _storage.flashcardsBox.get(id);
    if (flashcard == null) return;

    // Move to trash
    final trashItem = TrashItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      itemType: 'flashcard',
      originalId: flashcard.id,
      deletedAt: DateTime.now(),
      payload: flashcard.toMap(),
      parentId: flashcard.deckId,
    );
    await _storage.trashBox.put(trashItem.id, trashItem);
    await _storage.flashcardsBox.delete(id);

    // Update deck card count
    await _updateDeckCardCount(flashcard.deckId, -1);
  }

  /// Permanently delete a flashcard
  Future<void> permanentDelete(String id) async {
    _ensureInitialized();
    await _storage.flashcardsBox.delete(id);
  }

  /// Count flashcards
  int count() {
    _ensureInitialized();
    return _storage.flashcardsBox.length;
  }

  /// Count flashcards for a specific deck
  int countByDeckId(String deckId) {
    _ensureInitialized();
    return _storage.flashcardsBox.values
        .where((card) => card.deckId == deckId)
        .length;
  }

  /// Helper to update deck card count
  Future<void> _updateDeckCardCount(String deckId, int delta) async {
    final deck = _storage.decksBox.get(deckId);
    if (deck != null) {
      final updatedDeck = deck.copyWith(
        cardCount: deck.cardCount + delta,
        updatedAt: DateTime.now(),
      );
      await _storage.decksBox.put(deckId, updatedDeck);
    }
  }
}
