import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import 'anki_study_screen.dart';
import 'dart:async';

class MixedStudyScreen extends StatefulWidget {
  final Deck? customDeck;
  final List<Flashcard>? customFlashcards;

  const MixedStudyScreen({
    super.key,
    this.customDeck,
    this.customFlashcards,
  });

  @override
  State<MixedStudyScreen> createState() => _MixedStudyScreenState();
}

class _MixedStudyScreenState extends State<MixedStudyScreen> {
  final DataService _dataService = DataService();
  final NotificationService _notificationService = NotificationService();
  
  List<Flashcard> _overdueCards = [];
  List<Flashcard> _cardsDueToday = [];
  List<Deck> _allDecks = [];
  bool _isLoading = true;
  bool _isStartingStudy = false;

  @override
  void initState() {
    super.initState();
    _loadMixedStudyData();
  }

  Future<void> _loadMixedStudyData() async {
    setState(() => _isLoading = true);
    
    try {
      if (widget.customDeck != null && widget.customFlashcards != null) {
        // Use custom deck and flashcards
        if (mounted) {
          setState(() {
            _allDecks = [widget.customDeck!];
            _overdueCards = widget.customFlashcards!;
            _cardsDueToday = [];
            _isLoading = false;
          });
        }
      } else {
        // Load all decks first
        final decks = await _dataService.getDecks();
        
        // Load overdue and due cards
        final overdueCards = await _notificationService.getOverdueCards();
        final cardsDueToday = await _notificationService.getCardsDueToday();
        
        // Combine all cards that need review
        final allCardsToReview = [...overdueCards, ...cardsDueToday];
        
        // Remove duplicates (in case a card appears in both lists)
        final uniqueCards = <String, Flashcard>{};
        for (final card in allCardsToReview) {
          uniqueCards[card.id] = card;
        }
        
        if (mounted) {
          setState(() {
            _allDecks = decks;
            _overdueCards = overdueCards;
            _cardsDueToday = cardsDueToday;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      print('Error loading mixed study data: $e');
    }
  }

  void _startMixedStudy() async {
    setState(() => _isStartingStudy = true);
    
    try {
      List<Flashcard> cardsToStudy;
      
      if (widget.customDeck != null && widget.customFlashcards != null) {
        // Use custom flashcards
        cardsToStudy = widget.customFlashcards!;
      } else {
        // Combine all cards that need review
        final allCardsToReview = [..._overdueCards, ..._cardsDueToday];
        
        // Remove duplicates
        final uniqueCards = <String, Flashcard>{};
        for (final card in allCardsToReview) {
          uniqueCards[card.id] = card;
        }
        
        cardsToStudy = uniqueCards.values.toList();
      }
      
      if (cardsToStudy.isEmpty) {
        if (mounted) {
          SnackbarUtils.showWarningSnackbar(
            context,
            'No cards to study!',
          );
        }
        return;
      }

      // Create a virtual "Mixed Study" deck for the study session
      final mixedDeck = widget.customDeck ?? Deck(
        id: 'mixed_study_session',
        name: 'Mixed Study',
        description: 'Cards from all decks that need review',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        coverColor: '26A69A', // Warm teal color for mixed study
        spacedRepetitionEnabled: false, // Don't affect schedules for custom study
        showStudyStats: true,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnkiStudyScreen(
              deck: mixedDeck,
              flashcards: cardsToStudy,
            ),
          ),
        ).then((_) {
          // Refresh data when returning from study
          _loadMixedStudyData();
        });
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showErrorSnackbar(
          context,
          'Error starting mixed study: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isStartingStudy = false);
      }
    }
  }

  Color _getDeckColor(String deckId) {
    try {
      final deck = _allDecks.firstWhere((d) => d.id == deckId);
      return Color(int.parse('0xFF${deck.coverColor ?? '2196F3'}'));
    } catch (e) {
      return Colors.blue; // Default color
    }
  }

  String _getDeckName(String deckId) {
    try {
      final deck = _allDecks.firstWhere((d) => d.id == deckId);
      return deck.name;
    } catch (e) {
      return 'Unknown Deck';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5);
    final primaryColor = const Color(0xFF26A69A); // Warm teal - cozy and inviting
    final primaryDark = const Color(0xFF00897B);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(widget.customDeck?.name ?? 'Mixed Study'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (widget.customDeck == null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadMixedStudyData,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF26A69A);
    final primaryDark = const Color(0xFF00897B);
    
    final totalCardsToReview = widget.customFlashcards?.length ?? (_overdueCards.length + _cardsDueToday.length);
    
    if (totalCardsToReview == 0) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Header with study info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor,
                primaryDark,
              ],
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.shuffle,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                widget.customDeck?.name ?? 'Mixed Study Session',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.customFlashcards != null 
                    ? '$totalCardsToReview cards across all decks'
                    : '$totalCardsToReview cards need review',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.customFlashcards != null
                            ? 'This session includes all cards from across all packs and decks. Study results won\'t affect your regular schedules.'
                            :'This session includes all cards from across all packs and decks. Study results won\'t affect your regular schedules.',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Study button
        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isStartingStudy ? null : _startMixedStudy,
              icon: _isStartingStudy 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.play_arrow, size: 24),
              label: Text(
                _isStartingStudy 
                    ? 'Starting Study...' 
                    : 'Start Mixed Study',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF26A69A);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'All Caught Up! 🎉',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No cards need review at the moment.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadMixedStudyData,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}