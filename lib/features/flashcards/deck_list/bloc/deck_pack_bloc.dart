import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/models/deck.dart';
import '../../../../core/models/deck_pack.dart';
import '../../../../core/services/data_service.dart';
import '../../../../core/utils/logger.dart';
import 'deck_pack_event.dart';
import 'deck_pack_state.dart';

/// BLoC for managing deck pack list state
/// This eliminates direct setState() calls and optimizes rebuilds
class DeckPackBloc extends Bloc<DeckPackEvent, DeckPackState> {
  final DataService _dataService;

  DeckPackBloc({DataService? dataService})
      : _dataService = dataService ?? locator.dataService,
        super(const DeckPackInitial()) {
    on<LoadDeckPacks>(_onLoadDeckPacks);
    on<RefreshDeckPacks>(_onRefreshDeckPacks);
    on<TogglePackExpansion>(_onTogglePackExpansion);
    on<CreateDeckPack>(_onCreateDeckPack);
    on<UpdateDeckPack>(_onUpdateDeckPack);
    on<DeleteDeckPack>(_onDeleteDeckPack);
    on<CreateDeck>(_onCreateDeck);
    on<DeleteDeck>(_onDeleteDeck);
  }

  Future<void> _onLoadDeckPacks(
    LoadDeckPacks event,
    Emitter<DeckPackState> emit,
  ) async {
    emit(const DeckPackLoading());
    
    try {
      // Ensure data service is initialized
      if (!_dataService.isInitialized) {
        await _dataService.initialize();
      }

      // Load deck packs and decks in parallel
      final results = await Future.wait([
        _dataService.getDeckPacks(),
        _dataService.getDecks(),
      ]);

      final deckPacks = results[0] as List<DeckPack>;
      final allDecks = results[1] as List<Deck>;

      // Organize decks by pack
      final decksInPacks = <String, List<Deck>>{};
      for (final deckPack in deckPacks) {
        decksInPacks[deckPack.id] = 
            allDecks.where((deck) => deck.packId == deckPack.id).toList();
      }

      emit(DeckPackLoaded(
        deckPacks: deckPacks,
        decksInPacks: decksInPacks,
      ));
    } catch (e) {
      AppLogger.error('Error loading deck packs', error: e);
      emit(DeckPackError('Failed to load deck packs: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshDeckPacks(
    RefreshDeckPacks event,
    Emitter<DeckPackState> emit,
  ) async {
    // Keep current state while refreshing
    final currentState = state;
    
    try {
      final results = await Future.wait([
        _dataService.getDeckPacks(),
        _dataService.getDecks(),
      ]);

      final deckPacks = results[0] as List<DeckPack>;
      final allDecks = results[1] as List<Deck>;

      final decksInPacks = <String, List<Deck>>{};
      for (final deckPack in deckPacks) {
        decksInPacks[deckPack.id] = 
            allDecks.where((deck) => deck.packId == deckPack.id).toList();
      }

      // Preserve expanded state if available
      final expandedPackIds = currentState is DeckPackLoaded 
          ? currentState.expandedPackIds 
          : <String>{};

      emit(DeckPackLoaded(
        deckPacks: deckPacks,
        decksInPacks: decksInPacks,
        expandedPackIds: expandedPackIds,
      ));
    } catch (e) {
      AppLogger.error('Error refreshing deck packs', error: e);
      // Keep current state on error
    }
  }

  void _onTogglePackExpansion(
    TogglePackExpansion event,
    Emitter<DeckPackState> emit,
  ) {
    if (state is! DeckPackLoaded) return;

    final currentState = state as DeckPackLoaded;
    final expandedPackIds = Set<String>.from(currentState.expandedPackIds);

    if (expandedPackIds.contains(event.packId)) {
      // Collapse this pack
      expandedPackIds.remove(event.packId);
    } else {
      // Collapse all others and expand this one
      expandedPackIds.clear();
      expandedPackIds.add(event.packId);
    }

    emit(currentState.copyWith(expandedPackIds: expandedPackIds));
  }

  Future<void> _onCreateDeckPack(
    CreateDeckPack event,
    Emitter<DeckPackState> emit,
  ) async {
    try {
      await _dataService.createDeckPack(
        event.name,
        event.description,
        coverColor: event.coverColor,
      );
      
      // Refresh the list
      add(const RefreshDeckPacks());
    } catch (e) {
      AppLogger.error('Error creating deck pack', error: e);
      emit(DeckPackError('Failed to create deck pack: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateDeckPack(
    UpdateDeckPack event,
    Emitter<DeckPackState> emit,
  ) async {
    try {
      await _dataService.updateDeckPack(event.deckPack);
      add(const RefreshDeckPacks());
    } catch (e) {
      AppLogger.error('Error updating deck pack', error: e);
      emit(DeckPackError('Failed to update deck pack: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteDeckPack(
    DeleteDeckPack event,
    Emitter<DeckPackState> emit,
  ) async {
    try {
      await _dataService.deleteDeckPack(event.packId);
      add(const RefreshDeckPacks());
    } catch (e) {
      AppLogger.error('Error deleting deck pack', error: e);
      emit(DeckPackError('Failed to delete deck pack: ${e.toString()}'));
    }
  }

  Future<void> _onCreateDeck(
    CreateDeck event,
    Emitter<DeckPackState> emit,
  ) async {
    try {
      final deck = await _dataService.createDeck(
        event.name,
        event.description,
        coverColor: event.coverColor,
      );
      
      await _dataService.addDeckToPack(deck.id, event.packId);
      add(const RefreshDeckPacks());
    } catch (e) {
      AppLogger.error('Error creating deck', error: e);
      emit(DeckPackError('Failed to create deck: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteDeck(
    DeleteDeck event,
    Emitter<DeckPackState> emit,
  ) async {
    try {
      await _dataService.deleteDeck(event.deckId);
      add(const RefreshDeckPacks());
    } catch (e) {
      AppLogger.error('Error deleting deck', error: e);
      emit(DeckPackError('Failed to delete deck: ${e.toString()}'));
    }
  }
}
