import 'package:flutter/material.dart';
import '../../../../core/models/deck.dart';
import '../../../../core/models/deck_pack.dart';
import '../../../../core/models/flashcard.dart';

/// State management for Flow-Scroll Review feature
/// Tracks active pack, current card, progress, and transitions
class FlowScrollController extends ChangeNotifier {
  static const int cardsPerDeck = 5; // Cards before switching packs
  static const double activeZoneStart = 0.3; // 30% from top
  static const double activeZoneEnd = 0.7; // 70% from top (40% zone)
  
  String? _activePackId;
  Map<String, List<Flashcard>> _deckFlashcards = {};
  Map<String, int> _currentCardIndex = {}; // Track current card per deck
  Map<String, int> _cardsReviewed = {}; // Track how many cards reviewed per deck
  double _scrollProgress = 0.0; // 0.0 = question shown, 1.0 = answer revealed
  bool _isFlowMode = false;
  
  String? get activePackId => _activePackId;
  bool get isFlowMode => _isFlowMode;
  double get scrollProgress => _scrollProgress;
  
  /// Get current card for active deck
  Flashcard? getCurrentCard(String deckId) {
    if (!_deckFlashcards.containsKey(deckId)) return null;
    final cards = _deckFlashcards[deckId]!;
    final index = _currentCardIndex[deckId] ?? 0;
    return index < cards.length ? cards[index] : null;
  }
  
  /// Get progress for a deck (0.0 to 1.0)
  double getDeckProgress(String deckId) {
    final reviewed = _cardsReviewed[deckId] ?? 0;
    return reviewed / cardsPerDeck;
  }
  
  /// Check if deck has more cards to review
  bool hasMoreCards(String deckId) {
    final reviewed = _cardsReviewed[deckId] ?? 0;
    return reviewed < cardsPerDeck;
  }
  
  /// Initialize flashcards for a deck
  void setDeckFlashcards(String deckId, List<Flashcard> flashcards) {
    _deckFlashcards[deckId] = flashcards;
    _currentCardIndex[deckId] = 0;
    _cardsReviewed[deckId] = 0;
    notifyListeners();
  }
  
  /// Update which pack is currently active based on scroll position
  void updateActivePackFromScroll(
    List<DeckPack> deckPacks,
    ScrollController scrollController,
    BuildContext context,
  ) {
    if (!scrollController.hasClients) return;
    
    final screenHeight = MediaQuery.of(context).size.height;
    final activeZoneTop = screenHeight * activeZoneStart;
    final activeZoneBottom = screenHeight * activeZoneEnd;
    final activeZoneCenter = (activeZoneTop + activeZoneBottom) / 2;
    
    // Find which deck pack is in the active zone
    String? newActivePackId;
    for (int i = 0; i < deckPacks.length; i++) {
      // Approximate card position (this is simplified - in real impl we'd track actual positions)
      final itemTop = i * 120.0 - scrollController.offset; // Approx card height
      final itemBottom = itemTop + 120.0;
      final itemCenter = (itemTop + itemBottom) / 2;
      
      // Check if item center is in active zone
      if (itemCenter >= activeZoneTop && itemCenter <= activeZoneBottom) {
        newActivePackId = deckPacks[i].id;
        break;
      }
    }
    
    if (newActivePackId != _activePackId) {
      _activePackId = newActivePackId;
      _scrollProgress = 0.0; // Reset scroll progress when changing packs
      notifyListeners();
    }
  }
  
  /// Update scroll progress within the current card (0.0 = question, 1.0 = answer revealed)
  void updateScrollProgress(double delta) {
    if (!_isFlowMode || _activePackId == null) return;
    
    _scrollProgress = (_scrollProgress + delta).clamp(0.0, 2.0);
    
    // If scroll progress exceeds 1.5, move to next card
    if (_scrollProgress >= 1.5) {
      _moveToNextCard();
    }
    
    notifyListeners();
  }
  
  /// Move to next card in active deck
  void _moveToNextCard() {
    if (_activePackId == null) return;
    
    // Find a deck in this pack that has flashcards
    final firstDeckWithCards = _deckFlashcards.keys.firstWhere(
      (deckId) => deckId.startsWith(_activePackId!),
      orElse: () => '',
    );
    
    if (firstDeckWithCards.isEmpty) return;
    
    final currentIndex = _currentCardIndex[firstDeckWithCards] ?? 0;
    final cards = _deckFlashcards[firstDeckWithCards] ?? [];
    
    if (currentIndex + 1 < cards.length) {
      _currentCardIndex[firstDeckWithCards] = currentIndex + 1;
      _cardsReviewed[firstDeckWithCards] = (_cardsReviewed[firstDeckWithCards] ?? 0) + 1;
      _scrollProgress = 0.0;
    } else {
      // No more cards in this deck
      _cardsReviewed[firstDeckWithCards] = cardsPerDeck;
    }
    
    notifyListeners();
  }
  
  /// Toggle flow mode on/off
  void toggleFlowMode() {
    _isFlowMode = !_isFlowMode;
    if (!_isFlowMode) {
      _activePackId = null;
      _scrollProgress = 0.0;
    }
    notifyListeners();
  }
  
  /// Activate flow mode
  void activateFlowMode() {
    _isFlowMode = true;
    notifyListeners();
  }
  
  /// Deactivate flow mode
  void deactivateFlowMode() {
    _isFlowMode = false;
    _activePackId = null;
    _scrollProgress = 0.0;
    notifyListeners();
  }
  
  /// Reset all progress
  void reset() {
    _activePackId = null;
    _currentCardIndex.clear();
    _cardsReviewed.clear();
    _scrollProgress = 0.0;
    _isFlowMode = false;
    notifyListeners();
  }
}
