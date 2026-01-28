import '../models/note.dart';
import '../models/trash_item.dart';
import '../services/local_storage_service.dart';

/// Repository for Note CRUD operations.
class NoteRepository {
  final LocalStorageService _storage;

  NoteRepository({LocalStorageService? storage})
      : _storage = storage ?? LocalStorageService();

  void _ensureInitialized() {
    if (!_storage.areBoxesAccessible) {
      throw Exception('Storage not initialized. Call LocalStorageService.initialize() first.');
    }
  }

  /// Save a note exactly as provided (useful for sync/restore)
  Future<void> save(Note note) async {
    _ensureInitialized();
    await _storage.notesBox.put(note.id, note);
  }

  /// Create a new note
  Future<Note> create({
    required String title,
    required String content,
    String? linkedCardId,
    String? linkedDeckId,
    String? linkedPackId,
    List<String>? tags,
  }) async {
    _ensureInitialized();

    final now = DateTime.now();
    final note = Note(
      id: now.millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
      linkedCardId: linkedCardId,
      linkedDeckId: linkedDeckId,
      linkedPackId: linkedPackId,
      tags: tags ?? [],
    );

    await _storage.notesBox.put(note.id, note);
    return note;
  }

  /// Get all notes
  Future<List<Note>> getAll() async {
    _ensureInitialized();
    return _storage.notesBox.values.toList();
  }

  /// Get note by ID
  Future<Note?> getById(String id) async {
    _ensureInitialized();
    return _storage.notesBox.get(id);
  }

  /// Get notes linked to a specific item
  Future<List<Note>> getByLink({
    String? cardId,
    String? deckId,
    String? packId,
  }) async {
    _ensureInitialized();
    return _storage.notesBox.values.where((note) {
      if (cardId != null && note.linkedCardId == cardId) return true;
      if (deckId != null && note.linkedDeckId == deckId) return true;
      if (packId != null && note.linkedPackId == packId) return true;
      return false;
    }).toList();
  }

  /// Update a note
  Future<void> update(Note note) async {
    _ensureInitialized();
    final updatedNote = note.copyWith(updatedAt: DateTime.now());
    await _storage.notesBox.put(note.id, updatedNote);
  }

  /// Delete a note (moves to trash)
  Future<void> delete(String id) async {
    _ensureInitialized();

    final note = _storage.notesBox.get(id);
    if (note == null) return;

    final trashItem = TrashItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      itemType: 'note',
      originalId: note.id,
      deletedAt: DateTime.now(),
      payload: note.toMap(),
    );
    await _storage.trashBox.put(trashItem.id, trashItem);
    await _storage.notesBox.delete(id);
  }

  /// Permanently delete a note
  Future<void> permanentDelete(String id) async {
    _ensureInitialized();
    await _storage.notesBox.delete(id);
  }

  /// Count notes
  int count() {
    _ensureInitialized();
    return _storage.notesBox.length;
  }
}
