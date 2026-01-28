import '../models/deck.dart';
import '../models/trash_item.dart';
import '../services/local_storage_service.dart';

/// Repository for Deck CRUD operations.
/// Uses LocalStorageService for persistence.
class DeckRepository {
  final LocalStorageService _storage;

  DeckRepository({LocalStorageService? storage})
      : _storage = storage ?? LocalStorageService();

  void _ensureInitialized() {
    if (!_storage.areBoxesAccessible) {
      throw Exception('Storage not initialized. Call LocalStorageService.initialize() first.');
    }
  }

  /// Save a deck exactly as provided (useful for sync/restore)
  Future<void> save(Deck deck) async {
    _ensureInitialized();
    await _storage.decksBox.put(deck.id, deck);
  }

  /// Create a new deck
  Future<Deck> create({
    required String name,
    required String description,
    String? coverColor,
    String? packId,
  }) async {
    _ensureInitialized();

    final now = DateTime.now();
    final deck = Deck(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      createdAt: now,
      updatedAt: now,
      coverColor: coverColor,
      packId: packId,
    );

    await _storage.decksBox.put(deck.id, deck);
    return deck;
  }

  /// Get all decks
  Future<List<Deck>> getAll() async {
    _ensureInitialized();
    return _storage.decksBox.values.toList();
  }

  /// Get deck by ID
  Future<Deck?> getById(String id) async {
    _ensureInitialized();
    return _storage.decksBox.get(id);
  }

  /// Get decks by pack ID
  Future<List<Deck>> getByPackId(String packId) async {
    _ensureInitialized();
    return _storage.decksBox.values
        .where((deck) => deck.packId == packId)
        .toList();
  }

  /// Update a deck
  Future<void> update(Deck deck) async {
    _ensureInitialized();
    final updatedDeck = deck.copyWith(updatedAt: DateTime.now());
    await _storage.decksBox.put(deck.id, updatedDeck);
  }

  /// Delete a deck (moves to trash)
  Future<void> delete(String id) async {
    _ensureInitialized();

    final deck = _storage.decksBox.get(id);
    if (deck == null) return;

    // Move to trash
    final trashItem = TrashItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      itemType: 'deck',
      originalId: deck.id,
      deletedAt: DateTime.now(),
      payload: deck.toMap(),
    );
    await _storage.trashBox.put(trashItem.id, trashItem);

    // Delete associated flashcards
    final flashcards = _storage.flashcardsBox.values
        .where((card) => card.deckId == id)
        .toList();
    
    for (final card in flashcards) {
      final trashCard = TrashItem(
        id: '${DateTime.now().millisecondsSinceEpoch}_${card.id}',
        itemType: 'flashcard',
        originalId: card.id,
        deletedAt: DateTime.now(),
        payload: card.toMap(),
        parentId: id,
      );
      await _storage.trashBox.put(trashCard.id, trashCard);
      await _storage.flashcardsBox.delete(card.id);
    }

    await _storage.decksBox.delete(id);
  }

  /// Permanently delete a deck
  Future<void> permanentDelete(String id) async {
    _ensureInitialized();
    await _storage.decksBox.delete(id);
  }

  /// Count decks
  int count() {
    _ensureInitialized();
    return _storage.decksBox.length;
  }

  /// Get deck count for a specific pack
  int countByPackId(String packId) {
    _ensureInitialized();
    return _storage.decksBox.values
        .where((deck) => deck.packId == packId)
        .length;
  }
}
