import '../models/study_session.dart';
import '../services/local_storage_service.dart';

/// Repository for StudySession CRUD and stats operations.
class StudySessionRepository {
  final LocalStorageService _storage;

  StudySessionRepository({LocalStorageService? storage})
      : _storage = storage ?? LocalStorageService();

  void _ensureInitialized() {
    if (!_storage.areBoxesAccessible) {
      throw Exception('Storage not initialized. Call LocalStorageService.initialize() first.');
    }
  }

  /// Save a study session
  Future<void> save(StudySession session) async {
    _ensureInitialized();
    await _storage.studySessionsBox.put(session.id, session);
  }

  /// Get all study sessions
  Future<List<StudySession>> getAll() async {
    _ensureInitialized();
    return _storage.studySessionsBox.values.toList();
  }

  /// Get session by ID
  Future<StudySession?> getById(String id) async {
    _ensureInitialized();
    return _storage.studySessionsBox.get(id);
  }

  /// Get sessions for a specific deck
  Future<List<StudySession>> getByDeckId(String deckId) async {
    _ensureInitialized();
    return _storage.studySessionsBox.values
        .where((session) => session.deckId == deckId)
        .toList();
  }

  /// Get sessions within a date range
  Future<List<StudySession>> getByDateRange(DateTime start, DateTime end) async {
    _ensureInitialized();
    return _storage.studySessionsBox.values
        .where((session) => session.date.isAfter(start) && session.date.isBefore(end))
        .toList();
  }

  /// Get sessions for the last N days
  Future<List<StudySession>> getForLastDays(int days) async {
    _ensureInitialized();
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _storage.studySessionsBox.values
        .where((session) => session.date.isAfter(cutoffDate))
        .toList();
  }

  /// Delete a session
  Future<void> delete(String id) async {
    _ensureInitialized();
    await _storage.studySessionsBox.delete(id);
  }

  /// Count sessions
  int count() {
    _ensureInitialized();
    return _storage.studySessionsBox.length;
  }
}
