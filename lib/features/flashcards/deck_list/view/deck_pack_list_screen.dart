import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/core.dart';
import '../../../../core/services/adaptive_theme_service.dart';
import '../../../../core/services/background_service.dart';
import '../../../../core/animations/animated_wrappers.dart';
import '../../../../core/widgets/sync_dialog.dart';
import '../../../auth/services/auth_service.dart';
import '../../deck_management/screens/create_deck_pack_screen.dart';
import '../../deck_detail/view/deck_detail_screen.dart';
import '../../deck_management/screens/create_deck_screen.dart';
import '../../notes/screens/notes_screen.dart';
import '../../search/screens/search_screen.dart';
import '../../notifications/screens/notification_settings_screen.dart';
import '../../study/screens/mixed_study_screen.dart';
import '../../study/screens/anki_study_screen.dart';
import '../../../schedules/screens/my_schedules_screen.dart';
import '../bloc/bloc.dart';
import '../widgets/deck_pack_card.dart';
import '../widgets/deck_pack_notification_card.dart';
import '../widgets/deck_pack_list_drawer.dart';
import '../widgets/quick_actions_sheet.dart';
import '../widgets/streak_widget.dart';
import '../widgets/deck_pack_stats_header.dart';
import '../widgets/edge_navigator_strip.dart';
import '../services/streak_reminder_service.dart';
import '../../../../core/widgets/skeleton_loading.dart';
import '../widgets/vertical_edge_strip.dart';
import '../../../walkthrough/widgets/walkthrough_wrapper.dart';
import '../../../walkthrough/data/walkthrough_data.dart';
import '../widgets/burbly_ai_panel.dart';
import '../widgets/deck_pack_initials_strip.dart';

/// Premium DeckPackListScreen with enhanced UI
/// Features:
/// - Stats header with quick filters
/// - Edge navigator for quick alphabetical jumping
/// - Improved visual hierarchy
class DeckPackListScreen extends StatelessWidget {
  const DeckPackListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeckPackBloc(),
      child: const _DeckPackListScreenContent(),
    );
  }
}

class _DeckPackListScreenContent extends StatefulWidget {
  const _DeckPackListScreenContent();

  @override
  State<_DeckPackListScreenContent> createState() => _DeckPackListScreenContentState();
}

class _DeckPackListScreenContentState extends State<_DeckPackListScreenContent> {
  final AuthService _authService = AuthService();
  bool _isGuestMode = false;
  bool _isQuickActionsExpanded = false;
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  final ScrollController _scrollController = ScrollController();
  
  // Filter state
  String _selectedFilter = 'All';
  int _currentScrollIndex = 0;
  
  // Walkthrough GlobalKeys
  final GlobalKey _createPackKey = GlobalKey();
  final GlobalKey _statsHeaderKey = GlobalKey();
  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _quickActionsKey = GlobalKey();
  
  // AI Panel state
  final ValueNotifier<bool> _isAIPanelExpanded = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _checkGuestMode();
    
    // Defer data loading to after first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DeckPackBloc>().add(const LoadDeckPacks());
        _checkAndShowStreakReminder();
      }
    });

    // Track scroll position for edge navigator
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Calculate which pack is currently visible
    // This is a simplified calculation - you may want to enhance this
    if (_scrollController.hasClients) {
      final offset = _scrollController.offset;
      final index = (offset / 120).floor(); // Approximate item height
      if (index != _currentScrollIndex) {
        setState(() => _currentScrollIndex = index);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _isAIPanelExpanded.dispose();
    super.dispose();
  }

  Future<void> _checkAndShowStreakReminder() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    final shouldShow = await StreakReminderService.shouldShowStreakReminder();
    if (shouldShow && mounted) {
      final backgroundService = BackgroundService();
      final currentStreak = await backgroundService.getCurrentStreak();
      if (currentStreak > 0 && mounted) {
        StreakReminderService.showStreakReminderDialog(context, currentStreak);
      }
    }
  }

  Future<void> _checkGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _isGuestMode = prefs.getBool('isGuestMode') ?? false);
    }
  }

  void _onFilterChanged(String filter) {
    setState(() => _selectedFilter = filter);
    // TODO: Apply filter logic to the list
  }

  void _scrollToIndex(int index) {
    if (_scrollController.hasClients) {
      final offset = index * 120.0; // Approximate item height
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _createNewDeckPack() {
    context.pushScale(
      CreateDeckPackScreen(
        onDeckPackCreated: (deckPack) {
          context.read<DeckPackBloc>().add(const RefreshDeckPacks());
        },
      ),
    );
  }

  void _openDeck(Deck deck) {
    context.pushSharedAxis(
      DeckDetailScreen(deck: deck),
    ).then((_) {
      if (mounted) {
        context.read<DeckPackBloc>().add(const RefreshDeckPacks());
      }
    });
  }

  Future<void> _confirmDeleteDeck(Deck deck) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Deck'),
        content: Text('Are you sure you want to delete "${deck.name}" and all its flashcards?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<DeckPackBloc>().add(DeleteDeck(deck.id));
      SnackbarUtils.showWarningSnackbar(context, 'Deck "${deck.name}" moved to trash');
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.school, size: 36, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            const Text('Burbly Flashcard'),
          ],
        ),
        content: const Text(
          'Version 1.0.0\n\n'
          'A smart flashcard app that works offline and syncs your data when you sign in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    try {
      final result = await _authService.signInWithGoogle(forceAccountSelection: true);
      if (result != null && mounted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isGuestMode', false);
        setState(() => _isGuestMode = false);

        context.read<DeckPackBloc>().add(const LoadDeckPacks());
            
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully signed in!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _backupToCloud() async {
    try {
      SyncDialog.show(
        context,
        title: 'Backing up your data',
        message: 'Please wait while we securely sync your flashcards to the cloud...',
      );

      await locator.dataService.backupToFirestore();

      if (mounted) {
        SyncDialog.dismiss(context);
        
        SyncSuccessDialog.show(
          context,
          title: 'Backup Complete! ✓',
          message: 'Your flashcards have been successfully backed up to the cloud.',
        );
      }
    } catch (e) {
      if (mounted) {
        SyncDialog.dismiss(context);
        SnackbarUtils.showErrorSnackbar(
          context,
          'Backup failed: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOutGoogle();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isGuestMode', true);
      if (mounted) {
        setState(() => _isGuestMode = true);
        context.read<DeckPackBloc>().add(const LoadDeckPacks());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed out successfully'), backgroundColor: Colors.blue),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-out failed: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Quick action handlers
  void _onMixedStudy() async {
    try {
      final allFlashcards = <Flashcard>[];
      
      final state = context.read<DeckPackBloc>().state;
      if (state is DeckPackLoaded) {
        for (final deckPack in state.deckPacks) {
          final decks = state.decksInPacks[deckPack.id] ?? [];
          for (final deck in decks) {
            final deckFlashcards = await locator.dataService.getFlashcardsForDeck(deck.id);
            allFlashcards.addAll(deckFlashcards);
          }
        }
      }
      
      if (allFlashcards.isEmpty) {
        if (mounted) {
          SnackbarUtils.showWarningSnackbar(
            context,
            'No flashcards found in any deck!',
          );
        }
        return;
      }

      final mixedDeck = Deck(
        id: 'mixed_study_all_decks',
        name: 'Mixed Study - All Decks',
        description: 'All cards from all decks',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        coverColor: '9C27B0',
        spacedRepetitionEnabled: false,
        showStudyStats: true,
      );

      if (mounted) {
        context.pushSlide(
          MixedStudyScreen(
            customDeck: mixedDeck,
            customFlashcards: allFlashcards,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showErrorSnackbar(
          context,
          'Error starting mixed study: ${e.toString()}',
        );
      }
    }
  }

  void _onCalendar() {
    context.pushSlide(const MySchedulesScreen());
  }

  void _onBurblyAI() {
    SnackbarUtils.showInfoSnackbar(context, 'Burbly AI is coming soon! Stay tuned for AI-powered study assistance.');
  }

  void _openSearch() {
    context.pushSlide(const SearchScreen());
  }

  // Calculate stats from state
  Map<String, int> _calculateStats(DeckPackLoaded state) {
    int totalDecks = 0;
    int totalCards = 0;
    int decksToReview = 0;

    for (final deckPack in state.deckPacks) {
      final decks = state.decksInPacks[deckPack.id] ?? [];
      totalDecks += decks.length;
      for (final deck in decks) {
        totalCards += deck.cardCount;
        if (deck.deckIsReviewNow == true || deck.deckIsOverdue == true) {
          decksToReview++;
        }
      }
    }

    return {
      'packs': state.deckPacks.length,
      'decks': totalDecks,
      'cards': totalCards,
      'review': decksToReview,
    };
  }

  // Get pack names for edge navigator
  List<String> _getPackNames(DeckPackLoaded state) {
    return state.deckPacks.map((p) => p.name).toList();
  }

  // Filter deck packs based on selected filter
  List<DeckPack> _filterDeckPacks(DeckPackLoaded state) {
    switch (_selectedFilter) {
      case 'Review':
        return state.deckPacks.where((pack) {
          final decks = state.decksInPacks[pack.id] ?? [];
          return decks.any((d) => d.deckIsReviewNow == true || d.deckIsOverdue == true);
        }).toList();
      case 'Recent':
        final sorted = List<DeckPack>.from(state.deckPacks);
        sorted.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return sorted;
      case 'Large':
        final sorted = List<DeckPack>.from(state.deckPacks);
        sorted.sort((a, b) {
          final aCount = (state.decksInPacks[a.id] ?? []).length;
          final bCount = (state.decksInPacks[b.id] ?? []).length;
          return bCount.compareTo(aCount);
        });
        return sorted;
      default:
        return state.deckPacks;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define walkthrough highlights
    final highlights = WalkthroughData.getDeckPackListHighlights(
      createDeckKey: _createPackKey,
      deckCardKey: _statsHeaderKey,  // Using stats header as placeholder
      statsKey: _searchKey,
    );
    
    return WalkthroughWrapper(
      screenName: WalkthroughData.deckPackListScreen,
      highlights: highlights,
      child: Scaffold(
        appBar: AppBar(
  title: const Text(
    'Deck Packs',
    style: TextStyle(
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
    ),
  ),
  centerTitle: false, // or true – choose your preference
  elevation: 0,
  scrolledUnderElevation: 0,
  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
  actions: [
    // Streak widget – assuming it already has proper padding/margins inside
    Padding(
      padding: const EdgeInsets.only(right: 8),
      child: StreakWidget(),
    ),

    // Search button with showcase
    Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        icon: const Icon(Icons.search_rounded),
        tooltip: 'Search decks, cards & notes',
        iconSize: 26,
        onPressed: _openSearch,
      ).withShowcase(
        key: _searchKey,
        title: 'Search Everything',
        description: 'Quickly find any deck, card, or note across all your packs.',
      ),
    ),

    // Optional: Add more breathing room or a subtle separator if needed
    const SizedBox(width: 4),
  ],
  // Optional: subtle shadow only when scrolled
  // shadowColor: Colors.black.withOpacity(0.08),
),
      drawer: DeckPackListDrawer(
        isGuestMode: _isGuestMode,
        onSignInWithGoogle: _signInWithGoogle,
        onBackupToCloud: _backupToCloud,
        onSignOut: _signOut,
        onAbout: _showAboutDialog,
      ),
      body: ValueListenableBuilder<bool>(
          valueListenable: _isAIPanelExpanded,
          builder: (context, isAIPanelExpanded, child) {
            return Stack(
              children: [
                // Main content area with conditional width
                // Main content area - Always full width to prevent layout displacement
                Positioned.fill(
                  child: GestureDetector(
            onTap: _isQuickActionsExpanded
                ? () {
                    setState(() => _isQuickActionsExpanded = false);
                    _sheetController.animateTo(
                      0.12,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            child: Stack(
              children: [
                BlocBuilder<DeckPackBloc, DeckPackState>(
                  builder: (context, state) {
                    final isLoading = state is DeckPackLoading;
                    final isLoaded = state is DeckPackLoaded;
                    final isError = state is DeckPackError;
                    
                    return SmoothLoadingTransition(
                      isLoading: isLoading,
                      loadingWidget: const DeckPackListSkeleton(itemCount: 4),
                      child: isError
                          ? Center(child: Text((state as DeckPackError).message))
                          : isLoaded
                              ? Column(
                                  children: [
                                    // Stats Header
                                    Container(
                                      child: DeckPackStatsHeader(
                                        totalPacks: _calculateStats(state)['packs']!,
                                        totalDecks: _calculateStats(state)['decks']!,
                                        totalCards: _calculateStats(state)['cards']!,
                                        decksToReview: _calculateStats(state)['review']!,
                                        currentStreak: 0, // Will be fetched from BackgroundService
                                        selectedFilter: _selectedFilter,
                                        onFilterChanged: _onFilterChanged,
                                      ),
                                    ).withShowcase(
                                      key: _statsHeaderKey,
                                      title: 'Your Learning Stats',
                                      description: 'Track your progress with packs, decks, cards, and reviews at a glance.',
                                    ),
                                    
                                    // Deck Pack List
                                    Expanded(
                                      child: (state).deckPacks.isEmpty
                                          ? _buildEmptyState()
                                          : RefreshIndicator(
                                              onRefresh: () async {
                                                context.read<DeckPackBloc>().add(const RefreshDeckPacks());
                                              },
                                              child: ListView.builder(
                                                controller: _scrollController,
                                                padding: EdgeInsets.fromLTRB(
                                                  isAIPanelExpanded ? 4 : 12, 
                                                  12, 
                                                  isAIPanelExpanded ? 0 : 44, 
                                                  120
                                                ), 
                                                itemCount: _filterDeckPacks(state).length,
                                                itemBuilder: (context, index) {
                                                  final filteredPacks = _filterDeckPacks(state);
                                                  final deckPack = filteredPacks[index];
                                                  // Animate width of card when AI panel is expanded
                                                  return AnimatedContainer(
                                                    duration: const Duration(milliseconds: 600),
                                                    curve: Curves.easeOutQuart,
                                                    // When expanded, shrink to fit initials only (approx 50px)
                                                    width: isAIPanelExpanded ? 50 : MediaQuery.of(context).size.width,
                                                    alignment: Alignment.centerLeft,
                                                    child: DeckPackNotificationCard(
                                                      deckPack: deckPack,
                                                      decks: (state).decksInPacks[deckPack.id] ?? [],
                                                      // Force collapse details when shrunk
                                                      isExpanded: (state).expandedPackIds.contains(deckPack.id) && !isAIPanelExpanded,
                                                      isCompactMode: isAIPanelExpanded,
                                                      onToggle: () {
                                                        if (isAIPanelExpanded) {
                                                           // If tapped while shrunk, expand panel back? Or just ignore?
                                                           // Let's close AI panel to restore view
                                                           _isAIPanelExpanded.value = false;
                                                        } else {
                                                          context.read<DeckPackBloc>().add(TogglePackExpansion(deckPack.id));
                                                        }
                                                      },
                                                      onOptions: () => _showDeckPackOptions(deckPack),
                                                      onCreateDeck: () => _createNewDeck(deckPack),
                                                      onOpenDeck: _openDeck,
                                                      onDeleteDeck: _confirmDeleteDeck,
                                                      formatDate: _formatDate,
                                                      listIndex: index,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                    );
                  },
                ),
                
                // Vertical Edge Strip
                const VerticalEdgeStrip(),
                
                // Blur overlay
                if (_isQuickActionsExpanded)
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: Container(
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        // Burbly AI Panel (Handles both collapsed and expanded states)
        BurblyAIPanel(
          isExpandedNotifier: _isAIPanelExpanded,
        ),
        
        if (_isQuickActionsExpanded)
  if (_isQuickActionsExpanded)
  Positioned.fill(
    child: TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,   // ← buttery smooth natural deceleration
      builder: (context, value, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 12.0 * value,
            sigmaY: 12.0 * value,
          ),
          child: Container(
            color: Colors.black.withOpacity(0.28 * value),
          ),
        );
      },
    ),
  ),
          
          // Quick actions sheet
          QuickActionsSheet(
            controller: _sheetController,
            onExpansionChanged: (isExpanded) {
              setState(() => _isQuickActionsExpanded = isExpanded);
            },
            actions: QuickActionsSheet.defaultActions(
              onMixedStudy: _onMixedStudy,
              onCalendar: _onCalendar,
              onBurblyAI: _onBurblyAI,
            ),
          ),
        ],
      );
    },
  ),
        floatingActionButton: FloatingActionButton(
          onPressed: _createNewDeckPack,
          child: const Icon(Icons.folder_open),
        ).withShowcase(
          key: _createPackKey,
          title: 'Create Your First Pack',
          description: 'Organize your flashcards into themed packs for better learning.',
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_open, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No deck packs yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Create your first deck pack to get started'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _createNewDeckPack,
            child: const Text('Create Deck Pack'),
          ),
        ],
      ),
    );
  }

  void _showDeckPackOptions(DeckPack deckPack) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Add Deck'),
            onTap: () {
              Navigator.pop(context);
              _createNewDeck(deckPack);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete Pack', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _deleteDeckPack(deckPack);
            },
          ),
        ],
      ),
    );
  }

  void _createNewDeck(DeckPack deckPack) {
    context.pushScale(
      CreateDeckScreen(
        initialPackId: deckPack.id,
        onDeckCreated: (deck) {
          context.read<DeckPackBloc>().add(const RefreshDeckPacks());
        },
      ),
    );
  }

  Future<void> _deleteDeckPack(DeckPack deckPack) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Deck Pack'),
        content: Text('Are you sure you want to delete "${deckPack.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<DeckPackBloc>().add(DeleteDeckPack(deckPack.id));
    }
  }
}