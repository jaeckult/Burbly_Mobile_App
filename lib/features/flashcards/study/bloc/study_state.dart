import 'package:equatable/equatable.dart';
import '../../../../core/core.dart';

class StudyState extends Equatable {
  final List<Flashcard> flashcards;
  final int currentIndex;
  final bool showAnswer;
  final bool isLoading;
  final bool isPaused;
  final int cardsStudied;
  final double averageScore;
  final String? error;

  const StudyState({
    this.flashcards = const [],
    this.currentIndex = 0,
    this.showAnswer = false,
    this.isLoading = false,
    this.isPaused = false,
    this.cardsStudied = 0,
    this.averageScore = 0.0,
    this.error,
  });

  StudyState copyWith({
    List<Flashcard>? flashcards,
    int? currentIndex,
    bool? showAnswer,
    bool? isLoading,
    bool? isPaused,
    int? cardsStudied,
    double? averageScore,
    String? error,
  }) {
    return StudyState(
      flashcards: flashcards ?? this.flashcards,
      currentIndex: currentIndex ?? this.currentIndex,
      showAnswer: showAnswer ?? this.showAnswer,
      isLoading: isLoading ?? this.isLoading,
      isPaused: isPaused ?? this.isPaused,
      cardsStudied: cardsStudied ?? this.cardsStudied,
      averageScore: averageScore ?? this.averageScore,
      error: error ?? this.error,
    );
  }

  bool get hasMoreCards => currentIndex < flashcards.length - 1;
  bool get isLastCard => currentIndex == flashcards.length - 1;
  Flashcard? get currentCard => flashcards.isNotEmpty ? flashcards[currentIndex] : null;
  double get progress => flashcards.isNotEmpty ? (currentIndex + 1) / flashcards.length : 0.0;

  @override
  List<Object?> get props => [
        flashcards,
        currentIndex,
        showAnswer,
        isLoading,
        isPaused,
        cardsStudied,
        averageScore,
        error,
      ];
}

