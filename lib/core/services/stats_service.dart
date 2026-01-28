import '../repositories/deck_repository.dart';
import '../repositories/study_session_repository.dart';
import '../models/study_session.dart';
import 'compute_service.dart';

/// Service for calculating study statistics.
class StatsService {
  final DeckRepository _deckRepository;
  final StudySessionRepository _sessionRepository;
  final ComputeService _computeService = ComputeService();

  // Cache for stats with TTL
  final Map<String, _CachedStats> _deckStatsCache = {};
  _CachedStats? _overallStatsCache;
  static const _cacheDuration = Duration(minutes: 5);

  StatsService({
    required DeckRepository deckRepository,
    required StudySessionRepository sessionRepository,
  })  : _deckRepository = deckRepository,
        _sessionRepository = sessionRepository;

  /// Calculate statistics for a specific deck (with caching)
  Future<Map<String, dynamic>> getDeckStats(String deckId) async {
    // Check cache first
    final cached = _deckStatsCache[deckId];
    if (cached != null && !cached.isExpired) {
      return cached.data;
    }

    final sessions = await _sessionRepository.getByDeckId(deckId);
    
    if (sessions.isEmpty) {
      final emptyStats = {
        'totalSessions': 0,
        'averageScore': 0.0,
        'totalStudyTime': 0,
        'bestScore': 0.0,
        'cardsStudied': 0,
      };
      _deckStatsCache[deckId] = _CachedStats(emptyStats);
      return emptyStats;
    }

    // Convert sessions to maps for isolate
    final sessionMaps = sessions.map((s) => {
      'averageScore': s.averageScore,
      'studyTimeSeconds': s.studyTimeSeconds,
      'totalCards': s.totalCards,
    }).toList();

    // Calculate in background isolate
    final stats = await _computeService.calculateDeckStats(sessions: sessionMaps);
    
    // Cache the result
    _deckStatsCache[deckId] = _CachedStats(stats);
    return stats;
  }

  /// Calculate overall statistics across all decks and sessions (with caching)
  Future<Map<String, dynamic>> getOverallStats() async {
    // Check cache first
    if (_overallStatsCache != null && !_overallStatsCache!.isExpired) {
      return _overallStatsCache!.data;
    }

    final sessions = await _sessionRepository.getAll();
    final decks = await _deckRepository.getAll();
    
    final totalDecks = decks.length;
    final totalCards = decks.fold<int>(0, (sum, deck) => sum + deck.cardCount);

    if (sessions.isEmpty) {
      final emptyStats = {
        'totalSessions': 0,
        'totalDecks': totalDecks,
        'totalCards': totalCards,
        'averageScore': 0.0,
        'totalStudyTime': 0,
      };
      _overallStatsCache = _CachedStats(emptyStats);
      return emptyStats;
    }

    // Convert sessions to maps for isolate
    final sessionMaps = sessions.map((s) => {
      'averageScore': s.averageScore,
      'studyTimeSeconds': s.studyTimeSeconds,
    }).toList();

    // Calculate in background isolate
    final stats = await _computeService.calculateOverallStats(
      sessions: sessionMaps,
      totalDecks: totalDecks,
      totalCards: totalCards,
    );
    
    // Cache the result
    _overallStatsCache = _CachedStats(stats);
    return stats;
  }

  /// Get study volume for a chart (e.g., sessions per day for last N days)
  Future<Map<DateTime, int>> getStudyVolume(int days) async {
    final sessions = await _sessionRepository.getForLastDays(days);
    final Map<DateTime, int> volume = {};
    
    for (final session in sessions) {
      final date = DateTime(session.date.year, session.date.month, session.date.day);
      volume[date] = (volume[date] ?? 0) + 1;
    }
    
    return volume;
  }

  /// Invalidate cache for a specific deck (call after new study session)
  void invalidateDeckCache(String deckId) {
    _deckStatsCache.remove(deckId);
    _overallStatsCache = null; // Also invalidate overall stats
  }

  /// Invalidate all caches
  void invalidateAllCaches() {
    _deckStatsCache.clear();
    _overallStatsCache = null;
  }
}

/// Helper class for cached stats with expiration
class _CachedStats {
  final Map<String, dynamic> data;
  final DateTime cachedAt;

  _CachedStats(this.data) : cachedAt = DateTime.now();

  bool get isExpired {
    return DateTime.now().difference(cachedAt) > StatsService._cacheDuration;
  }
}
