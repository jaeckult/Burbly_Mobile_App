import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/core.dart';
import '../../../../core/animations/animated_wrappers.dart';
import '../../../../core/widgets/skeleton_loading.dart';
import '../../deck_management/screens/create_deck_screen.dart';
import '../../deck_detail/view/deck_detail_screen.dart';
import '../bloc/bloc.dart';
import '../widgets/bento_grid_view.dart';

/// Detail screen for a specific deck pack.
/// Displays decks within the pack using Bento Grid.
class DeckPackDetailScreen extends StatefulWidget {
  final DeckPack deckPack;

  const DeckPackDetailScreen({super.key, required this.deckPack});

  @override
  State<DeckPackDetailScreen> createState() => _DeckPackDetailScreenState();
}

class _DeckPackDetailScreenState extends State<DeckPackDetailScreen> {
  late DeckPack _currentPack;

  @override
  void initState() {
    super.initState();
    _currentPack = widget.deckPack;
    
    // Ensure data is loaded when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Check if bloc has data, if not trigger a load
        final bloc = context.read<DeckPackBloc>();
        if (bloc.state is! DeckPackLoaded) {
          bloc.add(const LoadDeckPacks());
        }
      }
    });
  }

  void _createNewDeck() {
    context.pushScale(
      CreateDeckScreen(
        initialPackId: _currentPack.id,
        onDeckCreated: (deck) {
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

  Future<void> _editPack() async {
    final nameController = TextEditingController(text: _currentPack.name);
    final descriptionController = TextEditingController(text: _currentPack.description);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Deck Pack'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedPack = _currentPack.copyWith(
                name: nameController.text.trim(),
                description: descriptionController.text.trim(),
                updatedAt: DateTime.now(),
              );
              context.read<DeckPackBloc>().add(UpdateDeckPack(updatedPack));
              setState(() => _currentPack = updatedPack);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePack() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Deck Pack'),
        content: Text(
          'Are you sure you want to delete "${_currentPack.name}"? '
          'This will NOT delete the decks inside, but they will be moved to "Uncategorized".',
        ),
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
      context.read<DeckPackBloc>().add(DeleteDeckPack(_currentPack.id));
      Navigator.pop(context); // Go back to list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPack.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editPack,
            tooltip: 'Edit Pack',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deletePack,
            tooltip: 'Delete Pack',
          ),
        ],
      ),
      body: BlocBuilder<DeckPackBloc, DeckPackState>(
        builder: (context, state) {
          final isLoading = state is DeckPackLoading;
          final isLoaded = state is DeckPackLoaded;
          final isError = state is DeckPackError;

          // Find current pack in state to keep stats up to date
          if (isLoaded) {
            final pack = (state as DeckPackLoaded).deckPacks
                .where((p) => p.id == _currentPack.id)
                .firstOrNull;
            if (pack != null) {
              _currentPack = pack; // Update local ref if found (might be deleted)
            }
          }

          return SmoothLoadingTransition(
            isLoading: isLoading,
            loadingWidget: const DeckGridSkeleton(),
            child: isError
                ? Center(child: Text((state as DeckPackError).message))
                : isLoaded
                    ? _buildContent(state as DeckPackLoaded)
                    : const SizedBox.shrink(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewDeck,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(DeckPackLoaded state) {
    final decksInPack = state.decksInPacks[_currentPack.id] ?? [];
    
    // Debug logging
    print('DeckPackDetailScreen - Building content for pack: ${_currentPack.name} (${_currentPack.id})');
    print('DeckPackDetailScreen - Total packs in state: ${state.deckPacks.length}');
    print('DeckPackDetailScreen - Decks in this pack: ${decksInPack.length}');
    print('DeckPackDetailScreen - All pack IDs in state: ${state.decksInPacks.keys.toList()}');
    
    // Also check all decks to see their packIds
    for (final packId in state.decksInPacks.keys) {
      final decks = state.decksInPacks[packId] ?? [];
      print('DeckPackDetailScreen - Pack $packId has ${decks.length} decks');
      for (final deck in decks) {
        print('  Deck: ${deck.name} (packId: ${deck.packId})');
      }
    }
    
    // Create map for BentoGridView (though we know the pack)
    final deckPacksById = {_currentPack.id: _currentPack};

    if (decksInPack.isEmpty) {
      // Gather all decks from all packs for debugging
      final allDecksInfo = <String>[];
      for (final packId in state.decksInPacks.keys) {
        final decks = state.decksInPacks[packId] ?? [];
        for (final deck in decks) {
          allDecksInfo.add('${deck.name} (pack: ${deck.packId?.substring(0, 8) ?? "null"})');
        }
      }
      
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.folder_open, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No decks in this pack',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'Looking for Pack ID: ${_currentPack.id.substring(0, 8)}...',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                'Total packs in state: ${state.deckPacks.length}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Text(
                'All decks in state (${allDecksInfo.length}):',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[700]),
              ),
              ...allDecksInfo.take(10).map((info) => Text(
                info,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              )),
              if (allDecksInfo.length > 10)
                Text(
                  '... and ${allDecksInfo.length - 10} more',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _createNewDeck,
                child: const Text('Create Deck'),
              ),
            ],
          ),
        ),
      );
    }

    // Sort decks similar to main dashboard
    final sortedDecks = List<Deck>.from(decksInPack);
    sortedDecks.sort((a, b) {
      if (a.deckIsOverdue == true && b.deckIsOverdue != true) return -1;
      if (b.deckIsOverdue == true && a.deckIsOverdue != true) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return BentoGridView(
      decks: sortedDecks,
      deckPacksById: deckPacksById,
      onDeckTap: _openDeck,
      onDeckLongPress: _confirmDeleteDeck,
    );
  }
}
