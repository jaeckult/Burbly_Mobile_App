import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/data_service.dart';
import '../../../../core/services/overdue_service.dart';
import '../../../../core/models/deck.dart';
import '../../../../core/models/flashcard.dart';
import 'deck_detail_event.dart';
import 'deck_detail_state.dart';

class DeckDetailBloc extends Bloc<DeckDetailEvent, DeckDetailState> {
  final DataService _dataService;
  final OverdueService _overdueService;
  Timer? _timer;

  DeckDetailBloc({DataService? dataService, OverdueService? overdueService, required Deck initialDeck})
      : _dataService = dataService ?? DataService(),
        _overdueService = overdueService ?? OverdueService(),
        super(DeckDetailState(deck: initialDeck, isLoading: true)) {
    on<InitializeDeck>(_onInitialize);
    on<LoadFlashcards>(_onLoadFlashcards);
    on<RefreshRequested>(_onRefresh);
    on<PeriodicTick>(_onPeriodicTick);
    on<ToggleSpacedRepetition>(_onToggleSrs);
    on<ToggleShowStudyStats>(_onToggleStats);
    on<UpdateTimerDuration>(_onUpdateTimer);
    on<EditDeckRequested>(_onEditDeck);
    on<EditFlashcardRequested>(_onEditFlashcard);
    on<DeleteFlashcardRequested>(_onDeleteFlashcard);

    // Start periodic timer each 30s
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => add(const PeriodicTick()));
  }

  Future<void> _onInitialize(InitializeDeck event, Emitter<DeckDetailState> emit) async {
    emit(state.copyWith(deck: event.deck, isLoading: true, clearError: true));
    if (event.deck.spacedRepetitionEnabled) {
      _overdueService.startOverdueMonitoring();
    }
    await _refreshAll(emit);
  }

  Future<void> _onLoadFlashcards(LoadFlashcards event, Emitter<DeckDetailState> emit) async {
    try {
      final List<Flashcard> cards = await _dataService.getFlashcardsForDeck(state.deck.id);
      emit(state.copyWith(flashcards: cards, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Failed to load flashcards: $e'));
    }
  }

  Future<void> _onRefresh(RefreshRequested event, Emitter<DeckDetailState> emit) async {
    await _refreshAll(emit);
  }

  Future<void> _onPeriodicTick(PeriodicTick event, Emitter<DeckDetailState> emit) async {
    await _refreshAll(emit);
  }

  Future<void> _refreshAll(Emitter<DeckDetailState> emit) async {
    try {
      final allDecks = await _dataService.getDecks();
      final updatedDeck = allDecks.firstWhere(
        (d) => d.id == state.deck.id,
        orElse: () => state.deck,
      );
      final flash = await _dataService.getFlashcardsForDeck(updatedDeck.id);
      emit(state.copyWith(deck: updatedDeck, flashcards: flash, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Failed to refresh: $e'));
    }
  }

  Future<void> _onToggleSrs(ToggleSpacedRepetition event, Emitter<DeckDetailState> emit) async {
    try {
      final updated = state.deck.copyWith(spacedRepetitionEnabled: event.enabled);
      await _dataService.updateDeck(updated);
      emit(state.copyWith(deck: updated));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error updating spaced repetition: $e'));
    }
  }

  Future<void> _onToggleStats(ToggleShowStudyStats event, Emitter<DeckDetailState> emit) async {
    try {
      final updated = state.deck.copyWith(showStudyStats: event.visible);
      await _dataService.updateDeck(updated);
      emit(state.copyWith(deck: updated));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error updating study stats: $e'));
    }
  }

  Future<void> _onUpdateTimer(UpdateTimerDuration event, Emitter<DeckDetailState> emit) async {
    try {
      final updated = state.deck.copyWith(timerDuration: event.seconds);
      await _dataService.updateDeck(updated);
      emit(state.copyWith(deck: updated));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error updating timer: $e'));
    }
  }

  Future<void> _onEditDeck(EditDeckRequested event, Emitter<DeckDetailState> emit) async {
    try {
      final updated = state.deck.copyWith(
        name: event.name.trim(),
        description: event.description.trim(),
        coverColor: event.coverColor ?? state.deck.coverColor,
        updatedAt: DateTime.now(),
      );
      await _dataService.updateDeck(updated);
      emit(state.copyWith(deck: updated));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error updating deck: $e'));
    }
  }

  Future<void> _onEditFlashcard(EditFlashcardRequested event, Emitter<DeckDetailState> emit) async {
    try {
      await _dataService.updateFlashcard(event.flashcard);
      add(const LoadFlashcards());
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error updating flashcard: $e'));
    }
  }

  Future<void> _onDeleteFlashcard(DeleteFlashcardRequested event, Emitter<DeckDetailState> emit) async {
    try {
      await _dataService.deleteFlashcard(event.flashcardId);
      add(const LoadFlashcards());
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error deleting flashcard: $e'));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
