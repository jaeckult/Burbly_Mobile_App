import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/deck.dart';
import '../models/flashcard.dart';
import '../models/deck_pack.dart';
import '../models/note.dart';
import '../models/pet.dart';
import '../models/study_session.dart';
import '../models/trash_item.dart';
import '../utils/logger.dart';

/// Local storage service responsible for Hive initialization and box management.
/// This is the single source of truth for local data storage.
class LocalStorageService {
  static const String _decksBoxName = 'decks';
  static const String _flashcardsBoxName = 'flashcards';
  static const String _deckPacksBoxName = 'deck_packs';
  static const String _notesBoxName = 'notes';
  static const String _studySessionsBoxName = 'study_sessions';
  static const String _trashBoxName = 'trash';

  // Singleton instance
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  // Boxes
  late Box<Deck> _decksBox;
  late Box<Flashcard> _flashcardsBox;
  late Box<DeckPack> _deckPacksBox;
  late Box<Note> _notesBox;
  late Box<StudySession> _studySessionsBox;
  late Box<TrashItem> _trashBox;

  bool _isInitialized = false;

  // Public getters for boxes
  Box<Deck> get decksBox => _decksBox;
  Box<Flashcard> get flashcardsBox => _flashcardsBox;
  Box<DeckPack> get deckPacksBox => _deckPacksBox;
  Box<Note> get notesBox => _notesBox;
  Box<StudySession> get studySessionsBox => _studySessionsBox;
  Box<TrashItem> get trashBox => _trashBox;

  bool get isInitialized => _isInitialized;

  bool get areBoxesAccessible =>
      _isInitialized &&
      _decksBox.isOpen &&
      _flashcardsBox.isOpen &&
      _deckPacksBox.isOpen &&
      _notesBox.isOpen &&
      _studySessionsBox.isOpen &&
      _trashBox.isOpen;

  /// Initialize Hive and open all boxes
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Hive if not already done
      if (!Hive.isBoxOpen(_decksBoxName)) {
        await Hive.initFlutter();
        await _registerAdapters();
      }

      // Open all boxes
      _decksBox = await Hive.openBox<Deck>(_decksBoxName);
      _flashcardsBox = await Hive.openBox<Flashcard>(_flashcardsBoxName);
      _deckPacksBox = await Hive.openBox<DeckPack>(_deckPacksBoxName);
      _notesBox = await Hive.openBox<Note>(_notesBoxName);
      _studySessionsBox = await Hive.openBox<StudySession>(_studySessionsBoxName);
      _trashBox = await Hive.openBox<TrashItem>(_trashBoxName);

      _isInitialized = true;

      AppLogger.success('LocalStorageService initialized', tag: 'Storage');
      _logDataCounts();

      if (kDebugMode) {
        await _checkFirstLaunch();
      }
    } catch (e) {
      _isInitialized = false;
      AppLogger.error('Failed to initialize LocalStorageService', error: e, tag: 'Storage');
      throw Exception('Failed to initialize LocalStorageService: ${e.toString()}');
    }
  }

  /// Register all Hive adapters
  Future<void> _registerAdapters() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DeckAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(FlashcardAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(DeckPackAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(NoteAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(StudySessionAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(PetAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(PetTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(PetMoodAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(PetStageAdapter());
    }
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(TrashItemAdapter());
    }
  }

  void _logDataCounts() {
    AppLogger.dataIntegrity(
      'Decks: ${_decksBox.length}, '
      'Flashcards: ${_flashcardsBox.length}, '
      'DeckPacks: ${_deckPacksBox.length}, '
      'Notes: ${_notesBox.length}, '
      'Sessions: ${_studySessionsBox.length}',
      tag: 'Storage',
    );
  }

  Future<void> _checkFirstLaunch() async {
    final totalItems = _decksBox.length +
        _flashcardsBox.length +
        _deckPacksBox.length +
        _notesBox.length +
        _studySessionsBox.length;

    if (totalItems == 0) {
      final prefs = await SharedPreferences.getInstance();
      final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

      if (isFirstLaunch) {
        AppLogger.info('First app launch detected', tag: 'Storage');
        await prefs.setBool('isFirstLaunch', false);
      } else {
        AppLogger.warning('Not first launch but no data found', tag: 'Storage');
      }
    }
  }

  /// Reinitialize storage (close and reopen boxes)
  Future<void> reinitialize() async {
    if (_isInitialized) {
      await _safeCloseBoxes();
    }
    _isInitialized = false;
    await initialize();
  }

  /// Clear all local data
  Future<void> clearAllData() async {
    if (!_isInitialized) {
      await initialize();
    }
    try {
      await _decksBox.clear();
      await _flashcardsBox.clear();
      await _deckPacksBox.clear();
      await _notesBox.clear();
      await _studySessionsBox.clear();
      await _trashBox.clear();
      invalidateCountsCache(); // Invalidate cache after clearing
      AppLogger.info('All local data cleared', tag: 'Storage');
    } catch (e) {
      AppLogger.error('Failed to clear local data', error: e, tag: 'Storage');
      rethrow;
    }
  }

  Future<void> _safeCloseBoxes() async {
    try {
      if (_decksBox.isOpen) await _decksBox.close();
      if (_flashcardsBox.isOpen) await _flashcardsBox.close();
      if (_deckPacksBox.isOpen) await _deckPacksBox.close();
      if (_notesBox.isOpen) await _notesBox.close();
      if (_studySessionsBox.isOpen) await _studySessionsBox.close();
      if (_trashBox.isOpen) await _trashBox.close();
    } catch (e) {
      AppLogger.error('Error closing boxes', error: e, tag: 'Storage');
    }
  }

  DateTime? _lastCountsUpdate;
  Map<String, int>? _cachedCounts;
  static const _countsCacheDuration = Duration(seconds: 5);

  /// Get data counts for integrity checking (cached for performance)
  Future<Map<String, int>> getDataCounts() async {
    if (!_isInitialized) {
      throw Exception('LocalStorageService has not been initialized.');
    }
    
    // Return cached counts if still valid
    if (_cachedCounts != null && 
        _lastCountsUpdate != null &&
        DateTime.now().difference(_lastCountsUpdate!) < _countsCacheDuration) {
      return _cachedCounts!;
    }
    
    // Calculate counts (potentially expensive)
    final counts = {
      'decks': _decksBox.length,
      'flashcards': _flashcardsBox.length,
      'deckPacks': _deckPacksBox.length,
      'notes': _notesBox.length,
      'studySessions': _studySessionsBox.length,
      'trash': _trashBox.length,
    };
    
    // Cache the results
    _cachedCounts = counts;
    _lastCountsUpdate = DateTime.now();
    
    return counts;
  }

  /// Invalidate the counts cache (call after data modifications)
  void invalidateCountsCache() {
    _cachedCounts = null;
    _lastCountsUpdate = null;
  }

  /// Check data integrity
  Future<Map<String, dynamic>> checkDataIntegrity() async {
    try {
      final counts = await getDataCounts();
      final totalItems = counts.values.reduce((a, b) => a + b);

      return {
        'totalItems': totalItems,
        'boxesAccessible': areBoxesAccessible,
        'isDebugMode': kDebugMode,
        'counts': counts,
        'status': totalItems > 0 ? 'healthy' : 'empty',
      };
    } catch (e) {
      AppLogger.error('Data integrity check failed', error: e, tag: 'Storage');
      return {'error': e.toString(), 'status': 'error'};
    }
  }
}
