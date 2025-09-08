import 'package:equatable/equatable.dart';

abstract class StatsEvent extends Equatable {
  const StatsEvent();

  @override
  List<Object?> get props => [];
}

class LoadStats extends StatsEvent {
  const LoadStats();
}

class LoadDeckStats extends StatsEvent {
  final String deckId;

  const LoadDeckStats(this.deckId);

  @override
  List<Object?> get props => [deckId];
}

class LoadSpacedRepetitionStats extends StatsEvent {
  final String deckId;

  const LoadSpacedRepetitionStats(this.deckId);

  @override
  List<Object?> get props => [deckId];
}

class LoadOverallStats extends StatsEvent {
  const LoadOverallStats();
}

class RefreshStats extends StatsEvent {
  const RefreshStats();
}

class SetDateRange extends StatsEvent {
  final DateTime startDate;
  final DateTime endDate;

  const SetDateRange({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

