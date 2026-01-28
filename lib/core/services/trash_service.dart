import '../models/deck.dart';
import '../models/flashcard.dart';
import '../models/deck_pack.dart';
import '../models/note.dart';
import '../repositories/deck_repository.dart';
import '../repositories/flashcard_repository.dart';
import '../repositories/deck_pack_repository.dart';
import '../repositories/note_repository.dart';
import '../repositories/trash_repository.dart';
import '../utils/logger.dart';

/// Service for managing trash items and restoration.
class TrashService {
  final TrashRepository _trashRepo;
  final DeckRepository _deckRepo;
  final FlashcardRepository _flashcardRepo;
  final DeckPackRepository _deckPackRepo;
  final NoteRepository _noteRepo;

  TrashService({
    required TrashRepository trashRepo,
    required DeckRepository deckRepo,
    required FlashcardRepository flashcardRepo,
    required DeckPackRepository deckPackRepo,
    required NoteRepository noteRepo,
  })  : _trashRepo = trashRepo,
        _deckRepo = deckRepo,
        _flashcardRepo = flashcardRepo,
        _deckPackRepo = deckPackRepo,
        _noteRepo = noteRepo;

  /// Restore an item from trash back to its original repository
  Future<void> restore(String trashId) async {
    final trashItem = await _trashRepo.getById(trashId);
    if (trashItem == null) return;

    try {
      final payload = trashItem.payload;
      final type = trashItem.itemType;

      switch (type) {
        case 'deck':
          await _deckRepo.save(Deck.fromMap(payload));
          break;
        case 'flashcard':
          await _flashcardRepo.save(Flashcard.fromMap(payload));
          break;
        case 'deck_pack':
          await _deckPackRepo.save(DeckPack.fromMap(payload));
          break;
        case 'note':
          await _noteRepo.save(Note.fromMap(payload));
          break;
        default:
          AppLogger.warning('Unknown trash item type: $type', tag: 'Trash');
      }

      // Remove from trash after successful restoration
      await _trashRepo.permanentDelete(trashId);
      AppLogger.success('Restored $type from trash', tag: 'Trash');
    } catch (e) {
      AppLogger.error('Failed to restore item from trash', error: e, tag: 'Trash');
      rethrow;
    }
  }

  /// Get all items currently in trash
  Future<List<dynamic>> getAllTrashItems() => _trashRepo.getAll();
}
