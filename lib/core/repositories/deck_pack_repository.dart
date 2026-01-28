import '../models/deck_pack.dart';
import '../models/trash_item.dart';
import '../services/local_storage_service.dart';

/// Repository for DeckPack CRUD operations.
/// Uses LocalStorageService for persistence.
class DeckPackRepository {
  final LocalStorageService _storage;

  DeckPackRepository({LocalStorageService? storage})
      : _storage = storage ?? LocalStorageService();

  void _ensureInitialized() {
    if (!_storage.areBoxesAccessible) {
      throw Exception('Storage not initialized. Call LocalStorageService.initialize() first.');
    }
  }

  /// Save a deck pack exactly as provided (useful for sync/restore)
  Future<void> save(DeckPack deckPack) async {
    _ensureInitialized();
    await _storage.deckPacksBox.put(deckPack.id, deckPack);
  }

  /// Create a new deck pack
  Future<DeckPack> create({
    required String name,
    String? description,
    String? coverColor,
    List<String>? deckIds,
  }) async {
    _ensureInitialized();

    final now = DateTime.now();
    final deckPack = DeckPack(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      description: description ?? '',
      createdAt: now,
      updatedAt: now,
      coverColor: coverColor ?? '0xFF2196F3', // Default Blue color
      deckIds: deckIds ?? [],
    );

    await _storage.deckPacksBox.put(deckPack.id, deckPack);
    return deckPack;
  }

  /// Get all deck packs
  Future<List<DeckPack>> getAll() async {
    _ensureInitialized();
    return _storage.deckPacksBox.values.toList();
  }

  /// Get deck pack by ID
  Future<DeckPack?> getById(String id) async {
    _ensureInitialized();
    return _storage.deckPacksBox.get(id);
  }

  /// Get deck pack name by ID
  Future<String?> getNameById(String id) async {
    final pack = await getById(id);
    return pack?.name;
  }

  /// Update a deck pack
  Future<void> update(DeckPack deckPack) async {
    _ensureInitialized();
    final updatedPack = deckPack.copyWith(updatedAt: DateTime.now());
    await _storage.deckPacksBox.put(deckPack.id, updatedPack);
  }

  /// Add deck to pack
  Future<void> addDeckToPack(String packId, String deckId) async {
    _ensureInitialized();
    final pack = await getById(packId);
    if (pack == null) return;

    final updatedDeckIds = List<String>.from(pack.deckIds);
    if (!updatedDeckIds.contains(deckId)) {
      updatedDeckIds.add(deckId);
      final updatedPack = pack.copyWith(
        deckIds: updatedDeckIds,
        updatedAt: DateTime.now(),
      );
      await _storage.deckPacksBox.put(packId, updatedPack);
    }
  }

  /// Remove deck from pack
  Future<void> removeDeckFromPack(String packId, String deckId) async {
    _ensureInitialized();
    final pack = await getById(packId);
    if (pack == null) return;

    final updatedDeckIds = List<String>.from(pack.deckIds);
    updatedDeckIds.remove(deckId);
    final updatedPack = pack.copyWith(
      deckIds: updatedDeckIds,
      updatedAt: DateTime.now(),
    );
    await _storage.deckPacksBox.put(packId, updatedPack);
  }

  /// Delete a deck pack (moves to trash)
  Future<void> delete(String id) async {
    _ensureInitialized();

    final deckPack = _storage.deckPacksBox.get(id);
    if (deckPack == null) return;

    // Move to trash
    final trashItem = TrashItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      itemType: 'deck_pack',
      originalId: deckPack.id,
      deletedAt: DateTime.now(),
      payload: deckPack.toMap(),
    );
    await _storage.trashBox.put(trashItem.id, trashItem);
    await _storage.deckPacksBox.delete(id);
  }

  /// Permanently delete a deck pack
  Future<void> permanentDelete(String id) async {
    _ensureInitialized();
    await _storage.deckPacksBox.delete(id);
  }

  /// Count deck packs
  int count() {
    _ensureInitialized();
    return _storage.deckPacksBox.length;
  }

  /// Count decks in a pack
  int deckCount(String packId) {
    _ensureInitialized();
    final pack = _storage.deckPacksBox.get(packId);
    return pack?.deckIds.length ?? 0;
  }
}
