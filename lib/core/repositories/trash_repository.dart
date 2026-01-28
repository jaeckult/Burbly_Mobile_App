import '../models/trash_item.dart';
import '../services/local_storage_service.dart';

/// Repository for Trash operations (recover, permanent delete).
class TrashRepository {
  final LocalStorageService _storage;

  TrashRepository({LocalStorageService? storage})
      : _storage = storage ?? LocalStorageService();

  void _ensureInitialized() {
    if (!_storage.areBoxesAccessible) {
      throw Exception('Storage not initialized. Call LocalStorageService.initialize() first.');
    }
  }

  /// Save a trash item exactly as provided (useful for sync/restore)
  Future<void> save(TrashItem item) async {
    _ensureInitialized();
    await _storage.trashBox.put(item.id, item);
  }

  /// Get all trash items
  Future<List<TrashItem>> getAll() async {
    _ensureInitialized();
    return _storage.trashBox.values.toList();
  }

  /// Get trash item by ID
  Future<TrashItem?> getById(String id) async {
    _ensureInitialized();
    return _storage.trashBox.get(id);
  }

  /// Permanently delete a trash item
  Future<void> permanentDelete(String id) async {
    _ensureInitialized();
    await _storage.trashBox.delete(id);
  }

  /// Empty trash
  Future<void> emptyTrash() async {
    _ensureInitialized();
    await _storage.trashBox.clear();
  }

  /// Count trash items
  int count() {
    _ensureInitialized();
    return _storage.trashBox.length;
  }
  
  /// Recover an item from trash (this logic might need to interact with other repositories, 
  /// so actual recovery logic typically sits in a service layer that coordinates reps, 
  /// but basic moving back can be here if we had `put` access to other boxes, 
  /// keeping it simple: Repository just manages the trash box itself).
  /// 
  /// Note: Actual restoration requires knowing where to put it back.
}
