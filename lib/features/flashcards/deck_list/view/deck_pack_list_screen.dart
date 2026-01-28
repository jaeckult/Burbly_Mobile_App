import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/core.dart';
import '../../../../core/services/adaptive_theme_service.dart';
import '../../../../core/services/background_service.dart';
import '../../../auth/services/auth_service.dart';
import '../../deck_management/screens/create_deck_pack_screen.dart';
import '../../deck_detail/view/deck_detail_screen.dart';
import '../../deck_management/screens/create_deck_screen.dart';
import '../../notes/screens/notes_screen.dart';
import '../../search/screens/search_screen.dart';
import '../../notifications/screens/notification_settings_screen.dart';
import '../bloc/bloc.dart';
import '../widgets/deck_pack_card.dart';
import '../widgets/deck_pack_list_drawer.dart';

/// Refactored DeckPackListScreen using BLoC for state management.
/// This screen is now much smaller (approx. 500 lines vs 1700) and more performant.
class DeckPackListScreen extends StatelessWidget {
  const DeckPackListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Create BLoC without loading - loading is deferred to post-frame callback
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

  @override
  void initState() {
    super.initState();
    _checkGuestMode();
    
    // Defer data loading to after first frame is rendered
    // This prevents blocking the initial UI paint
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DeckPackBloc>().add(const LoadDeckPacks());
      }
    });
  }

  Future<void> _checkGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _isGuestMode = prefs.getBool('isGuestMode') ?? false);
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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _buildLoadingDialog(),
      );

      await locator.dataService.backupToFirestore();

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildLoadingDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            const Text('Backing up your data', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Please wait a moment...', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Burbly Flashcards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.pushSlide(const SearchScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewDeckPack,
          ),
        ],
      ),
      drawer: DeckPackListDrawer(
        isGuestMode: _isGuestMode,
        onSignInWithGoogle: _signInWithGoogle,
        onBackupToCloud: _backupToCloud,
        onSignOut: _signOut,
        onAbout: _showAboutDialog,
      ),
      body: BlocBuilder<DeckPackBloc, DeckPackState>(
        builder: (context, state) {
          if (state is DeckPackLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DeckPackLoaded) {
            if (state.deckPacks.isEmpty) {
              return _buildEmptyState();
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DeckPackBloc>().add(const RefreshDeckPacks());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.deckPacks.length,
                itemBuilder: (context, index) {
                  final deckPack = state.deckPacks[index];
                  return DeckPackCard(
                    deckPack: deckPack,
                    decks: state.decksInPacks[deckPack.id] ?? [],
                    isExpanded: state.expandedPackIds.contains(deckPack.id),
                    onToggle: () {
                      context.read<DeckPackBloc>().add(TogglePackExpansion(deckPack.id));
                    },
                    onOptions: () => _showDeckPackOptions(deckPack),
                    onCreateDeck: () => _createNewDeck(deckPack),
                    onOpenDeck: _openDeck,
                    onDeleteDeck: _confirmDeleteDeck,
                    formatDate: _formatDate,
                  );
                },
              ),
            );
          } else if (state is DeckPackError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewDeckPack,
        child: const Icon(Icons.folder_open),
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