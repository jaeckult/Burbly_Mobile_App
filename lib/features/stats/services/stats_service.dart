import '../../../core/core.dart';

class StatsService {
  final DataService _dataService = DataService();

  Future<Map<String, dynamic>> getOverallStats() async {
    return await _dataService.getOverallStats();
  }

  Future<List<StudySession>> getStudySessionsForDays(int days) async {
    return await _dataService.getStudySessionsForDays(days);
  }

  Future<List<Flashcard>> getAllFlashcards() async {
    return await _dataService.getAllFlashcards();
  }

  Future<void> syncFromCloud() async {
    await _dataService.initialize();
    await _dataService.loadDataFromFirestore();
  }
}

