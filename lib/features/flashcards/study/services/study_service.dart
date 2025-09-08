import '../../../../core/core.dart';

class StudyService {
  final DataService _dataService = DataService();

  Future<List<Flashcard>> getFlashcardsForStudy(String deckId) async {
    return await _dataService.getFlashcardsForDeck(deckId);
  }

  Future<void> updateFlashcardProgress(Flashcard flashcard) async {
    await _dataService.updateFlashcard(flashcard);
  }

  Future<void> recordStudySession(String deckId, int cardsStudied, double averageScore) async {
    // Build a StudySession with required fields and persist via DataService
    final correct = (cardsStudied * (averageScore / 4.0)).round();
    final incorrect = cardsStudied - correct;
    final session = StudySession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      deckId: deckId,
      date: DateTime.now(),
      totalCards: cardsStudied,
      correctAnswers: correct,
      incorrectAnswers: incorrect,
      averageScore: averageScore,
      studyTimeSeconds: 0,
      usedTimer: false,
    );
    await _dataService.saveStudySession(session);
  }

  Future<List<StudySession>> getStudySessions(String deckId) async {
    final allSessions = await _dataService.getAllStudySessions();
    return allSessions.where((session) => session.deckId == deckId).toList();
  }

  Future<Map<String, dynamic>> getStudyStats(String deckId) async {
    final sessions = await getStudySessions(deckId);
    final flashcards = await getFlashcardsForStudy(deckId);
    
    return {
      'totalSessions': sessions.length,
      'totalCards': flashcards.length,
      'averageScore': sessions.isNotEmpty 
          ? sessions.map((s) => s.averageScore).reduce((a, b) => a + b) / sessions.length 
          : 0.0,
    };
  }

  Future<List<Flashcard>> getDueCards(String deckId) async {
    final flashcards = await getFlashcardsForStudy(deckId);
    final now = DateTime.now();
    
    return flashcards.where((card) {
      if (card.nextReview == null) return true;
      return card.nextReview!.isBefore(now) || card.nextReview!.isAtSameMomentAs(now);
    }).toList();
  }

  Future<List<Flashcard>> getNewCards(String deckId, int limit) async {
    final flashcards = await getFlashcardsForStudy(deckId);
    final newCards = flashcards.where((card) => card.reviewCount == 0).toList();
    return newCards.take(limit).toList();
  }

  Future<List<Flashcard>> getReviewCards(String deckId) async {
    final flashcards = await getFlashcardsForStudy(deckId);
    return flashcards.where((card) => card.reviewCount > 0).toList();
  }
}
