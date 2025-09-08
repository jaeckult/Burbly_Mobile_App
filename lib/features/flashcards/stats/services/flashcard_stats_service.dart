import '../../../../core/core.dart';

class FlashcardStatsService {
  final DataService _dataService = DataService();

  Future<Map<String, dynamic>> getDeckStats(String deckId) async {
    final sessions = await getDeckStudySessions(deckId);
    final flashcards = await _dataService.getFlashcardsForDeck(deckId);
    
    return {
      'totalSessions': sessions.length,
      'totalCards': flashcards.length,
      'averageScore': sessions.isNotEmpty 
          ? sessions.map((s) => s.averageScore).reduce((a, b) => a + b) / sessions.length 
          : 0.0,
    };
  }

  Future<List<StudySession>> getDeckStudySessions(String deckId) async {
    final allSessions = await _dataService.getAllStudySessions();
    return allSessions.where((session) => session.deckId == deckId).toList();
  }

  Future<Map<String, dynamic>> getSpacedRepetitionStats(String deckId) async {
    final flashcards = await _dataService.getFlashcardsForDeck(deckId);
    final sessions = await getDeckStudySessions(deckId);
    
    // Calculate spaced repetition statistics
    final totalCards = flashcards.length;
    final newCards = flashcards.where((card) => card.reviewCount == 0).length;
    final learningCards = flashcards.where((card) => 
      card.reviewCount > 0 && card.reviewCount < 3).length;
    final reviewCards = flashcards.where((card) => card.reviewCount >= 3).length;
    
    // Calculate due cards
    final now = DateTime.now();
    final dueCards = flashcards.where((card) {
      if (card.nextReview == null) return true;
      return card.nextReview!.isBefore(now) || card.nextReview!.isAtSameMomentAs(now);
    }).length;

    // Calculate average ease factor
    final averageEaseFactor = flashcards.isNotEmpty 
        ? flashcards.map((card) => card.easeFactor).reduce((a, b) => a + b) / flashcards.length
        : 0.0;

    // Calculate study streak
    final studyStreak = _calculateStudyStreak(sessions);

    // Calculate retention rate
    final retentionRate = _calculateRetentionRate(sessions);

    return {
      'totalCards': totalCards,
      'newCards': newCards,
      'learningCards': learningCards,
      'reviewCards': reviewCards,
      'dueCards': dueCards,
      'averageEaseFactor': averageEaseFactor,
      'studyStreak': studyStreak,
      'retentionRate': retentionRate,
      'totalSessions': sessions.length,
    };
  }

  Future<Map<String, dynamic>> getOverallFlashcardStats() async {
    final allFlashcards = await _dataService.getAllFlashcards();
    final allSessions = await _dataService.getAllStudySessions();
    
    final totalCards = allFlashcards.length;
    final totalDecks = (await _dataService.getDecks()).length;
    final totalSessions = allSessions.length;
    
    // Calculate cards by difficulty
    final easyCards = allFlashcards.where((card) => card.easeFactor >= 2.3).length;
    final moderateCards = allFlashcards.where((card) => 
      card.easeFactor >= 2.0 && card.easeFactor < 2.3).length;
    final hardCards = allFlashcards.where((card) => 
      card.easeFactor >= 1.6 && card.easeFactor < 2.0).length;
    final insaneCards = allFlashcards.where((card) => card.easeFactor < 1.6).length;

    // Calculate study streak
    final studyStreak = _calculateStudyStreak(allSessions);

    // Calculate average score
    final averageScore = allSessions.isNotEmpty
        ? allSessions.map((session) => session.averageScore).reduce((a, b) => a + b) / allSessions.length
        : 0.0;

    return {
      'totalCards': totalCards,
      'totalDecks': totalDecks,
      'totalSessions': totalSessions,
      'easyCards': easyCards,
      'moderateCards': moderateCards,
      'hardCards': hardCards,
      'insaneCards': insaneCards,
      'studyStreak': studyStreak,
      'averageScore': averageScore,
    };
  }

  int _calculateStudyStreak(List<StudySession> sessions) {
    if (sessions.isEmpty) return 0;
    
    sessions.sort((a, b) => b.date.compareTo(a.date));
    int streak = 0;
    DateTime currentDate = DateTime.now();
    
    for (final session in sessions) {
      final sessionDate = DateTime(session.date.year, session.date.month, session.date.day);
      final checkDate = DateTime(currentDate.year, currentDate.month, currentDate.day);
      
      if (sessionDate.isAtSameMomentAs(checkDate) || 
          sessionDate.isAtSameMomentAs(checkDate.subtract(const Duration(days: 1)))) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    
    return streak;
  }

  double _calculateRetentionRate(List<StudySession> sessions) {
    if (sessions.isEmpty) return 0.0;
    
    final recentSessions = sessions.take(30).toList(); // Last 30 sessions
    if (recentSessions.isEmpty) return 0.0;
    
    final totalCards = recentSessions.fold<int>(0, (sum, session) => sum + session.totalCards);
    final averageScore = totalCards > 0 
        ? recentSessions.fold<double>(0, (sum, session) => 
            sum + (session.averageScore * session.totalCards)) / totalCards
        : 0.0;
    
    // Convert average score to retention rate (assuming 1-4 scale)
    return (averageScore / 4.0) * 100.0;
  }
}
