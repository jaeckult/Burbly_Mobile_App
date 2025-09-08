import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/core.dart';
import '../services/deck_management_service.dart';
import 'deck_management_event.dart';
import 'deck_management_state.dart';

class DeckManagementBloc extends Bloc<DeckManagementEvent, DeckManagementState> {
  final DeckManagementService _deckManagementService;

  DeckManagementBloc({
    required DeckManagementService deckManagementService,
  })  : _deckManagementService = deckManagementService,
        super(const DeckManagementState()) {
    on<LoadDecks>(_onLoadDecks);
    on<LoadDeckPacks>(_onLoadDeckPacks);
    on<CreateDeck>(_onCreateDeck);
    on<CreateDeckPack>(_onCreateDeckPack);
    on<UpdateDeck>(_onUpdateDeck);
    on<UpdateDeckPack>(_onUpdateDeckPack);
    on<DeleteDeck>(_onDeleteDeck);
    on<DeleteDeckPack>(_onDeleteDeckPack);
    on<AddFlashcard>(_onAddFlashcard);
    on<UpdateFlashcard>(_onUpdateFlashcard);
    on<DeleteFlashcard>(_onDeleteFlashcard);
    on<MoveDeckToPack>(_onMoveDeckToPack);
    on<RemoveDeckFromPack>(_onRemoveDeckFromPack);
  }

  Future<void> _onLoadDecks(LoadDecks event, Emitter<DeckManagementState> emit) async {
    emit(state.copyWith(status: DeckManagementStatus.loading));
    try {
      final decks = await _deckManagementService.getDecks();
      emit(state.copyWith(
        status: DeckManagementStatus.success,
        decks: decks,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DeckManagementStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadDeckPacks(LoadDeckPacks event, Emitter<DeckManagementState> emit) async {
    emit(state.copyWith(status: DeckManagementStatus.loading));
    try {
      final deckPacks = await _deckManagementService.getDeckPacks();
      emit(state.copyWith(
        status: DeckManagementStatus.success,
        deckPacks: deckPacks,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DeckManagementStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCreateDeck(CreateDeck event, Emitter<DeckManagementState> emit) async {
    emit(state.copyWith(isCreating: true));
    try {
      final deck = await _deckManagementService.createDeck(
        name: event.name,
        description: event.description,
        packId: event.packId,
      );
      if (deck == null) {
        emit(state.copyWith(isCreating: false));
        return;
      }
      final updatedDecks = List<Deck>.from(state.decks)..add(deck);
      emit(state.copyWith(
        isCreating: false,
        decks: updatedDecks,
      ));
    } catch (e) {
      emit(state.copyWith(
        isCreating: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCreateDeckPack(CreateDeckPack event, Emitter<DeckManagementState> emit) async {
    emit(state.copyWith(isCreating: true));
    try {
      final deckPack = await _deckManagementService.createDeckPack(
        name: event.name,
        description: event.description,
      );
      if (deckPack == null) {
        emit(state.copyWith(isCreating: false));
        return;
      }
      final updatedDeckPacks = List<DeckPack>.from(state.deckPacks)..add(deckPack);
      emit(state.copyWith(
        isCreating: false,
        deckPacks: updatedDeckPacks,
      ));
    } catch (e) {
      emit(state.copyWith(
        isCreating: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateDeck(UpdateDeck event, Emitter<DeckManagementState> emit) async {
    emit(state.copyWith(isUpdating: true));
    try {
      await _deckManagementService.updateDeck(event.deck);
      
      final updatedDecks = state.decks.map((deck) {
        return deck.id == event.deck.id ? event.deck : deck;
      }).toList();
      
      emit(state.copyWith(
        isUpdating: false,
        decks: updatedDecks,
      ));
    } catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateDeckPack(UpdateDeckPack event, Emitter<DeckManagementState> emit) async {
    emit(state.copyWith(isUpdating: true));
    try {
      await _deckManagementService.updateDeckPack(event.deckPack);
      
      final updatedDeckPacks = state.deckPacks.map((pack) {
        return pack.id == event.deckPack.id ? event.deckPack : pack;
      }).toList();
      
      emit(state.copyWith(
        isUpdating: false,
        deckPacks: updatedDeckPacks,
      ));
    } catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteDeck(DeleteDeck event, Emitter<DeckManagementState> emit) async {
    emit(state.copyWith(isDeleting: true));
    try {
      await _deckManagementService.deleteDeck(event.deckId);
      
      final updatedDecks = state.decks.where((deck) => deck.id != event.deckId).toList();
      emit(state.copyWith(
        isDeleting: false,
        decks: updatedDecks,
      ));
    } catch (e) {
      emit(state.copyWith(
        isDeleting: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteDeckPack(DeleteDeckPack event, Emitter<DeckManagementState> emit) async {
    emit(state.copyWith(isDeleting: true));
    try {
      await _deckManagementService.deleteDeckPack(event.packId);
      
      final updatedDeckPacks = state.deckPacks.where((pack) => pack.id != event.packId).toList();
      emit(state.copyWith(
        isDeleting: false,
        deckPacks: updatedDeckPacks,
      ));
    } catch (e) {
      emit(state.copyWith(
        isDeleting: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAddFlashcard(AddFlashcard event, Emitter<DeckManagementState> emit) async {
    try {
      final flashcard = await _deckManagementService.createFlashcard(
        deckId: event.deckId,
        question: event.question,
        answer: event.answer,
        extendedDescription: event.hint,
      );
      if (flashcard == null) {
        return;
      }
      
      final updatedFlashcards = Map<String, List<Flashcard>>.from(state.deckFlashcards);
      if (updatedFlashcards.containsKey(event.deckId)) {
        updatedFlashcards[event.deckId] = [...updatedFlashcards[event.deckId]!, flashcard];
      } else {
        updatedFlashcards[event.deckId] = [flashcard];
      }
      
      emit(state.copyWith(deckFlashcards: updatedFlashcards));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateFlashcard(UpdateFlashcard event, Emitter<DeckManagementState> emit) async {
    try {
      await _deckManagementService.updateFlashcard(event.flashcard);
      
      final updatedFlashcards = Map<String, List<Flashcard>>.from(state.deckFlashcards);
      if (updatedFlashcards.containsKey(event.flashcard.deckId)) {
        final flashcards = updatedFlashcards[event.flashcard.deckId]!;
        final updatedList = flashcards.map((card) {
          return card.id == event.flashcard.id ? event.flashcard : card;
        }).toList();
        updatedFlashcards[event.flashcard.deckId] = updatedList;
      }
      
      emit(state.copyWith(deckFlashcards: updatedFlashcards));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteFlashcard(DeleteFlashcard event, Emitter<DeckManagementState> emit) async {
    try {
      await _deckManagementService.deleteFlashcard(event.flashcardId);
      
      final updatedFlashcards = Map<String, List<Flashcard>>.from(state.deckFlashcards);
      for (final deckId in updatedFlashcards.keys) {
        updatedFlashcards[deckId] = updatedFlashcards[deckId]!
            .where((card) => card.id != event.flashcardId)
            .toList();
      }
      
      emit(state.copyWith(deckFlashcards: updatedFlashcards));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onMoveDeckToPack(MoveDeckToPack event, Emitter<DeckManagementState> emit) async {
    try {
      await _deckManagementService.moveDeckToPack(event.deckId, event.packId);
      
      final updatedDecks = state.decks.map((deck) {
        if (deck.id == event.deckId) {
          return deck.copyWith(packId: event.packId);
        }
        return deck;
      }).toList();
      
      emit(state.copyWith(decks: updatedDecks));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onRemoveDeckFromPack(RemoveDeckFromPack event, Emitter<DeckManagementState> emit) async {
    try {
      // Service does not provide a dedicated remove; update deck to null pack via updateDeck
      final idx = state.decks.indexWhere((d) => d.id == event.deckId);
      if (idx != -1) {
        final updated = state.decks[idx].copyWith(packId: null);
        await _deckManagementService.updateDeck(updated);
      }
      
      final updatedDecks = state.decks.map((deck) {
        if (deck.id == event.deckId) {
          return deck.copyWith(packId: null);
        }
        return deck;
      }).toList();
      
      emit(state.copyWith(decks: updatedDecks));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}

