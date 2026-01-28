import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/deck_repository.dart';
import '../repositories/flashcard_repository.dart';
import '../repositories/deck_pack_repository.dart';
import '../repositories/note_repository.dart';
import '../repositories/study_session_repository.dart';
import '../repositories/trash_repository.dart';
import '../models/deck.dart';
import '../models/flashcard.dart';
import '../models/deck_pack.dart';
import '../models/note.dart';
import '../models/study_session.dart';
import '../models/trash_item.dart';
import '../utils/logger.dart';

/// Service responsible for syncing local data with Firebase Firestore.
class SyncService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  
  final DeckRepository _deckRepository;
  final FlashcardRepository _flashcardRepository;
  final DeckPackRepository _deckPackRepository;
  final NoteRepository _noteRepository;
  final StudySessionRepository _studySessionRepository;
  final TrashRepository _trashRepository;

  SyncService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    DeckRepository? deckRepository,
    FlashcardRepository? flashcardRepository,
    DeckPackRepository? deckPackRepository,
    NoteRepository? noteRepository,
    StudySessionRepository? studySessionRepository,
    TrashRepository? trashRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _deckRepository = deckRepository ?? DeckRepository(),
        _flashcardRepository = flashcardRepository ?? FlashcardRepository(),
        _deckPackRepository = deckPackRepository ?? DeckPackRepository(),
        _noteRepository = noteRepository ?? NoteRepository(),
        _studySessionRepository = studySessionRepository ?? StudySessionRepository(),
        _trashRepository = trashRepository ?? TrashRepository();

  String? get _currentUserId => _auth.currentUser?.uid;

  /// Backup all local data to Firestore
  Future<void> backupToFirestore() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('You must be signed in to backup your data.');
    }

    try {
      AppLogger.sync('Starting backup to Firestore...');

      // Backup Deck Packs
      final deckPacks = await _deckPackRepository.getAll();
      AppLogger.sync('Backing up ${deckPacks.length} deck packs...');
      for (final pack in deckPacks) {
        await _saveItemToFirestore(userId, 'deck_packs', pack.id, pack.toMap());
      }

      // Backup Decks
      final decks = await _deckRepository.getAll();
      AppLogger.sync('Backing up ${decks.length} decks...');
      for (final deck in decks) {
        await _saveItemToFirestore(userId, 'decks', deck.id, deck.toMap());
      }

      // Backup Flashcards
      final flashcards = await _flashcardRepository.getAll();
      AppLogger.sync('Backing up ${flashcards.length} flashcards...');
      for (final card in flashcards) {
        await _saveItemToFirestore(userId, 'flashcards', card.id, card.toMap());
      }

      // Backup Notes
      final notes = await _noteRepository.getAll();
      AppLogger.sync('Backing up ${notes.length} notes...');
      for (final note in notes) {
        await _saveItemToFirestore(userId, 'notes', note.id, note.toMap());
      }

      // Backup Study Sessions
      final sessions = await _studySessionRepository.getAll();
      AppLogger.sync('Backing up ${sessions.length} study sessions...');
      for (final session in sessions) {
        await _saveItemToFirestore(userId, 'study_sessions', session.id, session.toMap());
      }
      
      // Backup Trash Items
      final trashItems = await _trashRepository.getAll();
      AppLogger.sync('Backing up ${trashItems.length} trash items...');
      for (final item in trashItems) {
        await _saveItemToFirestore(userId, 'trash', item.id, item.toMap());
      }

      // Backup Preferences
      await _backupPreferencesToFirestore();

      AppLogger.success('Backup completed successfully');
    } catch (e) {
      AppLogger.error('Backup failed', error: e);
      throw Exception('Backup failed: ${e.toString()}');
    }
  }

  /// Sync local data to Firestore (same as backup for now)
  Future<void> syncLocalDataToFirestore() async {
    if (_currentUserId == null) return;
    await backupToFirestore();
  }

  /// Load data from Firestore to local storage (Restore)
  Future<void> loadDataFromFirestore() async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      AppLogger.sync('Loading data from Firestore...');

      // Load Deck Packs
      final deckPacksSnapshot = await _getCollectionIds(userId, 'deck_packs');
      AppLogger.sync('Restoring ${deckPacksSnapshot.docs.length} deck packs...');
      for (final doc in deckPacksSnapshot.docs) {
        final pack = DeckPack.fromMap(doc.data());
        await _deckPackRepository.save(pack);
      }

      // Load Decks
      final decksSnapshot = await _getCollectionIds(userId, 'decks');
      AppLogger.sync('Restoring ${decksSnapshot.docs.length} decks...');
      for (final doc in decksSnapshot.docs) {
        final deck = Deck.fromMap(doc.data());
        await _deckRepository.save(deck);
      }

      // Load Flashcards
      final flashcardsSnapshot = await _getCollectionIds(userId, 'flashcards');
      AppLogger.sync('Restoring ${flashcardsSnapshot.docs.length} flashcards...');
      for (final doc in flashcardsSnapshot.docs) {
        final card = Flashcard.fromMap(doc.data());
        await _flashcardRepository.save(card);
      }

      // Load Notes
      final notesSnapshot = await _getCollectionIds(userId, 'notes');
      AppLogger.sync('Restoring ${notesSnapshot.docs.length} notes...');
      for (final doc in notesSnapshot.docs) {
        final note = Note.fromMap(doc.data());
        await _noteRepository.save(note);
      }

      // Load Study Sessions
      final sessionsSnapshot = await _getCollectionIds(userId, 'study_sessions');
      AppLogger.sync('Restoring ${sessionsSnapshot.docs.length} study sessions...');
      for (final doc in sessionsSnapshot.docs) {
        final session = StudySession.fromMap(doc.data());
        await _studySessionRepository.save(session);
      }
      
      // Load Trash
      final trashSnapshot = await _getCollectionIds(userId, 'trash');
      AppLogger.sync('Restoring ${trashSnapshot.docs.length} trash items...');
      for (final doc in trashSnapshot.docs) {
        final item = TrashItem.fromMap(doc.data());
        await _trashRepository.save(item);
      }

      // Load Preferences
      await _loadPreferencesFromFirestore();
      
      AppLogger.success('Data restore completed successfully');
    } catch (e) {
      AppLogger.error('Failed to load data from Firestore', error: e);
      rethrow;
    }
  }

  Future<void> _loadPreferencesFromFirestore() async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      final prefsDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('meta')
          .doc('preferences')
          .get();
      if (!prefsDoc.exists) return;
      final data = prefsDoc.data() ?? {};
      final prefs = await SharedPreferences.getInstance();

      if (data.containsKey('current_streak')) {
        await prefs.setInt('current_streak', (data['current_streak'] as num).toInt());
      }
      if (data.containsKey('last_study_date')) {
        await prefs.setString('last_study_date', data['last_study_date'] as String);
      }
      if (data.containsKey('last_streak_celebration')) {
        await prefs.setString('last_streak_celebration', data['last_streak_celebration'] as String);
      }
      if (data.containsKey('overdue_reminders_enabled')) {
        await prefs.setBool('overdue_reminders_enabled', data['overdue_reminders_enabled'] as bool);
      }
      if (data.containsKey('streak_reminders_enabled')) {
        await prefs.setBool('streak_reminders_enabled', data['streak_reminders_enabled'] as bool);
      }
      if (data.containsKey('reminder_hour')) {
        await prefs.setInt('reminder_hour', (data['reminder_hour'] as num).toInt());
      }
      if (data.containsKey('reminder_minute')) {
        await prefs.setInt('reminder_minute', (data['reminder_minute'] as num).toInt());
      }
      if (data.containsKey('reminder_days')) {
        final days = (data['reminder_days'] as List).map((e) => e.toString()).toList();
        await prefs.setStringList('reminder_days', days);
      }
      if (data.containsKey('last_overdue_check')) {
        await prefs.setString('last_overdue_check', data['last_overdue_check'] as String);
      }
      if (data.containsKey('last_reminder_check')) {
        await prefs.setString('last_reminder_check', data['last_reminder_check'] as String);
      }
    } catch (e) {
      AppLogger.error('Error loading preferences from Firestore', error: e);
    }
  }
  
  Future<void> _saveItemToFirestore(String userId, String collection, String docId, Map<String, dynamic> data) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection(collection)
        .doc(docId)
        .set(data);
  }

  Future<void> _backupPreferencesToFirestore() async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'current_streak': prefs.getInt('current_streak'),
        'last_study_date': prefs.getString('last_study_date'),
        'last_streak_celebration': prefs.getString('last_streak_celebration'),
        'overdue_reminders_enabled': prefs.getBool('overdue_reminders_enabled'),
        'streak_reminders_enabled': prefs.getBool('streak_reminders_enabled'),
        'reminder_hour': prefs.getInt('reminder_hour'),
        'reminder_minute': prefs.getInt('reminder_minute'),
        'reminder_days': prefs.getStringList('reminder_days')?.map((e) => int.parse(e)).toList(),
        'last_overdue_check': prefs.getString('last_overdue_check'),
        'last_reminder_check': prefs.getString('last_reminder_check'),
        'updated_at': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('meta')
          .doc('preferences')
          .set(data, SetOptions(merge: true));
    } catch (e) {
      AppLogger.error('Error backing up preferences', error: e);
    }
  }
  
  Future<QuerySnapshot<Map<String, dynamic>>> _getCollectionIds(String userId, String collection) {
    return _firestore.collection('users').doc(userId).collection(collection).get();
  }
}
