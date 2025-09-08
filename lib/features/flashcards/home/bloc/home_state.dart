import 'package:equatable/equatable.dart';
import '../../../../core/models/deck.dart';
import '../../../../core/models/flashcard.dart';
import '../../../../core/models/study_session.dart';
import '../../../../core/models/notification.dart';

enum HomeStatus {
  initial,
  loading,
  success,
  failure,
}

class HomeState extends Equatable {
  final HomeStatus status;
  final List<Deck> recentDecks;
  final List<Flashcard> dueCards;
  final List<StudySession> recentSessions;
  final List<AppNotification> notifications;
  final Map<String, dynamic> studyStats;
  final String? errorMessage;
  final bool isRefreshing;

  const HomeState({
    this.status = HomeStatus.initial,
    this.recentDecks = const [],
    this.dueCards = const [],
    this.recentSessions = const [],
    this.notifications = const [],
    this.studyStats = const {},
    this.errorMessage,
    this.isRefreshing = false,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<Deck>? recentDecks,
    List<Flashcard>? dueCards,
    List<StudySession>? recentSessions,
    List<AppNotification>? notifications,
    Map<String, dynamic>? studyStats,
    String? errorMessage,
    bool? isRefreshing,
  }) {
    return HomeState(
      status: status ?? this.status,
      recentDecks: recentDecks ?? this.recentDecks,
      dueCards: dueCards ?? this.dueCards,
      recentSessions: recentSessions ?? this.recentSessions,
      notifications: notifications ?? this.notifications,
      studyStats: studyStats ?? this.studyStats,
      errorMessage: errorMessage ?? this.errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
        status,
        recentDecks,
        dueCards,
        recentSessions,
        notifications,
        studyStats,
        errorMessage,
        isRefreshing,
      ];
}

