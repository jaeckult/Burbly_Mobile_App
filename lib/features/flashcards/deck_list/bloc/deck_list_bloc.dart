import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/deck.dart';
import '../services/deck_list_service.dart';
import 'deck_list_event.dart';
import 'deck_list_state.dart';

class DeckListBloc extends Bloc<DeckListEvent, DeckListState> {
  final DeckListService _deckListService;

  DeckListBloc({
    required DeckListService deckListService,
  })  : _deckListService = deckListService,
        super(const DeckListState()) {
    on<LoadDeckPacks>(_onLoadDeckPacks);
    on<RefreshDeckPacks>(_onRefreshDeckPacks);
    on<CreateDeckPack>(_onCreateDeckPack);
    on<UpdateDeckPack>(_onUpdateDeckPack);
    on<DeleteDeckPack>(_onDeleteDeckPack);
    on<CreateDeckInPack>(_onCreateDeckInPack);
    on<DeleteDeckFromPack>(_onDeleteDeckFromPack);
    on<TogglePackExpansion>(_onTogglePackExpansion);
  }

  Future<void> _onLoadDeckPacks(LoadDeckPacks event, Emitter<DeckListState> emit) async {
    emit(state.copyWith(status: DeckListStatus.loading));
    try {
      await _deckListService.initialize();
      
      final deckPacks = await _deckListService.getDeckPacks();
      final allDecks = await _deckListService.getAllDecks();
      final decksInPacks = await _deckListService.getDecksGroupedByPack();

      emit(state.copyWith(
        status: DeckListStatus.success,
        deckPacks: deckPacks,
        allDecks: allDecks,
        decksInPacks: decksInPacks,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DeckListStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshDeckPacks(RefreshDeckPacks event, Emitter<DeckListState> emit) async {
    emit(state.copyWith(isRefreshing: true));
    try {
      final deckPacks = await _deckListService.getDeckPacks();
      final allDecks = await _deckListService.getAllDecks();
      final decksInPacks = await _deckListService.getDecksGroupedByPack();

      emit(state.copyWith(
        isRefreshing: false,
        deckPacks: deckPacks,
        allDecks: allDecks,
        decksInPacks: decksInPacks,
      ));
    } catch (e) {
      emit(state.copyWith(
        isRefreshing: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCreateDeckPack(CreateDeckPack event, Emitter<DeckListState> emit) async {
    emit(state.copyWith(isCreating: true));
    try {
      final createdPack = await _deckListService.createDeckPack(
        event.deckPack.name,
        event.deckPack.description,
        coverColor: event.deckPack.coverColor,
      );
      
      final updatedDeckPacks = [...state.deckPacks, createdPack];
      final updatedDecksInPacks = Map<String, List<Deck>>.from(state.decksInPacks);
      updatedDecksInPacks[createdPack.id] = <Deck>[];
      
      final updatedExpandedPacks = Map<String, bool>.from(state.expandedPacks);
      updatedExpandedPacks[createdPack.id] = false;

      emit(state.copyWith(
        isCreating: false,
        deckPacks: updatedDeckPacks,
        decksInPacks: updatedDecksInPacks,
        expandedPacks: updatedExpandedPacks,
      ));
    } catch (e) {
      emit(state.copyWith(
        isCreating: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateDeckPack(UpdateDeckPack event, Emitter<DeckListState> emit) async {
    try {
      await _deckListService.updateDeckPack(event.deckPack);
      
      final updatedDeckPacks = state.deckPacks.map((pack) {
        return pack.id == event.deckPack.id ? event.deckPack : pack;
      }).toList();

      emit(state.copyWith(deckPacks: updatedDeckPacks));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteDeckPack(DeleteDeckPack event, Emitter<DeckListState> emit) async {
    emit(state.copyWith(isDeleting: true));
    try {
      await _deckListService.deleteDeckPack(event.packId);
      
      final updatedDeckPacks = state.deckPacks.where((pack) => pack.id != event.packId).toList();
      final updatedDecksInPacks = Map<String, List<Deck>>.from(state.decksInPacks);
      updatedDecksInPacks.remove(event.packId);
      
      final updatedExpandedPacks = Map<String, bool>.from(state.expandedPacks);
      updatedExpandedPacks.remove(event.packId);

      emit(state.copyWith(
        isDeleting: false,
        deckPacks: updatedDeckPacks,
        decksInPacks: updatedDecksInPacks,
        expandedPacks: updatedExpandedPacks,
      ));
    } catch (e) {
      emit(state.copyWith(
        isDeleting: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCreateDeckInPack(CreateDeckInPack event, Emitter<DeckListState> emit) async {
    emit(state.copyWith(isCreating: true));
    try {
      final createdDeck = await _deckListService.createDeck(
        event.deck.name,
        event.deck.description,
        coverColor: event.deck.coverColor,
        packId: event.deck.packId,
      );
      
      final updatedAllDecks = [...state.allDecks, createdDeck];
      final updatedDecksInPacks = Map<String, List<Deck>>.from(state.decksInPacks);
      
      if (createdDeck.packId != null) {
        final packsDecks = List<Deck>.from(updatedDecksInPacks[createdDeck.packId] ?? []);
        packsDecks.add(createdDeck);
        updatedDecksInPacks[createdDeck.packId!] = packsDecks;
      }

      emit(state.copyWith(
        isCreating: false,
        allDecks: updatedAllDecks,
        decksInPacks: updatedDecksInPacks,
      ));
    } catch (e) {
      emit(state.copyWith(
        isCreating: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteDeckFromPack(DeleteDeckFromPack event, Emitter<DeckListState> emit) async {
    emit(state.copyWith(isDeleting: true));
    try {
      await _deckListService.deleteDeck(event.deckId);
      
      final updatedAllDecks = state.allDecks.where((deck) => deck.id != event.deckId).toList();
      final updatedDecksInPacks = Map<String, List<Deck>>.from(state.decksInPacks);
      
      for (final packId in updatedDecksInPacks.keys) {
        final deckList = updatedDecksInPacks[packId];
        if (deckList != null) {
          updatedDecksInPacks[packId] = deckList
              .where((deck) => deck.id != event.deckId)
              .toList();
        }
      }

      emit(state.copyWith(
        isDeleting: false,
        allDecks: updatedAllDecks,
        decksInPacks: updatedDecksInPacks,
      ));
    } catch (e) {
      emit(state.copyWith(
        isDeleting: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onTogglePackExpansion(TogglePackExpansion event, Emitter<DeckListState> emit) async {
    final updatedExpandedPacks = Map<String, bool>.from(state.expandedPacks);
    updatedExpandedPacks[event.packId] = !(updatedExpandedPacks[event.packId] ?? false);
    
    emit(state.copyWith(expandedPacks: updatedExpandedPacks));
  }
}
