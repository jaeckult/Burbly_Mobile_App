import 'package:equatable/equatable.dart';

enum StatsStatus {
  initial,
  loading,
  success,
  failure,
}

class StatsState extends Equatable {
  final StatsStatus status;
  final Map<String, dynamic> deckStats;
  final Map<String, dynamic> spacedRepetitionStats;
  final Map<String, dynamic> overallStats;
  final String? errorMessage;
  final bool isRefreshing;
  final DateTime? startDate;
  final DateTime? endDate;

  const StatsState({
    this.status = StatsStatus.initial,
    this.deckStats = const {},
    this.spacedRepetitionStats = const {},
    this.overallStats = const {},
    this.errorMessage,
    this.isRefreshing = false,
    this.startDate,
    this.endDate,
  });

  StatsState copyWith({
    StatsStatus? status,
    Map<String, dynamic>? deckStats,
    Map<String, dynamic>? spacedRepetitionStats,
    Map<String, dynamic>? overallStats,
    String? errorMessage,
    bool? isRefreshing,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return StatsState(
      status: status ?? this.status,
      deckStats: deckStats ?? this.deckStats,
      spacedRepetitionStats: spacedRepetitionStats ?? this.spacedRepetitionStats,
      overallStats: overallStats ?? this.overallStats,
      errorMessage: errorMessage ?? this.errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [
        status,
        deckStats,
        spacedRepetitionStats,
        overallStats,
        errorMessage,
        isRefreshing,
        startDate,
        endDate,
      ];
}

