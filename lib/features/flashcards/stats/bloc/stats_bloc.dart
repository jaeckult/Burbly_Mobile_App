import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/flashcard_stats_service.dart';
import 'stats_event.dart';
import 'stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final FlashcardStatsService _statsService;

  StatsBloc({
    required FlashcardStatsService statsService,
  })  : _statsService = statsService,
        super(const StatsState()) {
    on<LoadStats>(_onLoadStats);
    on<LoadDeckStats>(_onLoadDeckStats);
    on<LoadSpacedRepetitionStats>(_onLoadSpacedRepetitionStats);
    on<LoadOverallStats>(_onLoadOverallStats);
    on<RefreshStats>(_onRefreshStats);
    on<SetDateRange>(_onSetDateRange);
  }

  Future<void> _onLoadStats(LoadStats event, Emitter<StatsState> emit) async {
    emit(state.copyWith(status: StatsStatus.loading));
    try {
      final overallStats = await _statsService.getOverallFlashcardStats();
      
      emit(state.copyWith(
        status: StatsStatus.success,
        overallStats: overallStats,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StatsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadDeckStats(LoadDeckStats event, Emitter<StatsState> emit) async {
    emit(state.copyWith(status: StatsStatus.loading));
    try {
      final deckStats = await _statsService.getDeckStats(event.deckId);
      
      emit(state.copyWith(
        status: StatsStatus.success,
        deckStats: deckStats,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StatsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadSpacedRepetitionStats(LoadSpacedRepetitionStats event, Emitter<StatsState> emit) async {
    emit(state.copyWith(status: StatsStatus.loading));
    try {
      final spacedRepetitionStats = await _statsService.getSpacedRepetitionStats(event.deckId);
      
      emit(state.copyWith(
        status: StatsStatus.success,
        spacedRepetitionStats: spacedRepetitionStats,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StatsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadOverallStats(LoadOverallStats event, Emitter<StatsState> emit) async {
    emit(state.copyWith(status: StatsStatus.loading));
    try {
      final overallStats = await _statsService.getOverallFlashcardStats();
      
      emit(state.copyWith(
        status: StatsStatus.success,
        overallStats: overallStats,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StatsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshStats(RefreshStats event, Emitter<StatsState> emit) async {
    emit(state.copyWith(isRefreshing: true));
    try {
      final overallStats = await _statsService.getOverallFlashcardStats();
      
      emit(state.copyWith(
        isRefreshing: false,
        overallStats: overallStats,
      ));
    } catch (e) {
      emit(state.copyWith(
        isRefreshing: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onSetDateRange(SetDateRange event, Emitter<StatsState> emit) {
    emit(state.copyWith(
      startDate: event.startDate,
      endDate: event.endDate,
    ));
  }
}

