import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../../core/models/deck.dart';
import '../../../../core/models/deck_pack.dart';
import '../../../../core/animations/animated_wrappers.dart';
import 'bento_deck_tile.dart';

/// A masonry grid view for displaying decks in a Bento Box layout.
/// Automatically determines tile sizes based on deck activity.
class BentoGridView extends StatelessWidget {
  final List<Deck> decks;
  final Map<String, DeckPack> deckPacksById;
  final Function(Deck) onDeckTap;
  final Function(Deck)? onDeckLongPress;
  final EdgeInsets? padding;

  const BentoGridView({
    super.key,
    required this.decks,
    required this.deckPacksById,
    required this.onDeckTap,
    this.onDeckLongPress,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (decks.isEmpty) {
      return const SizedBox.shrink();
    }

    // Determine number of columns based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth >= 600 ? 4 : 2;

    // Pre-calculate tile sizes for layout
    final tileData = decks.map((deck) {
      final size = BentoDeckTile.auto(
        deck: deck,
        onTap: () {},
      ).size;
      return _TileData(deck: deck, size: size);
    }).toList();

    return MasonryGridView.count(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      padding: padding ?? const EdgeInsets.all(16),
      itemCount: tileData.length,
      itemBuilder: (context, index) {
        final data = tileData[index];
        final deckPack = data.deck.packId != null 
            ? deckPacksById[data.deck.packId] 
            : null;

        return StaggeredListItem(
          index: index,
          child: SizedBox(
            height: _getHeightForSize(data.size),
            child: BentoDeckTile(
              deck: data.deck,
              deckPack: deckPack,
              size: data.size,
              onTap: () => onDeckTap(data.deck),
              onLongPress: onDeckLongPress != null 
                  ? () => onDeckLongPress!(data.deck) 
                  : null,
            ),
          ),
        );
      },
    );
  }

  double _getHeightForSize(BentoTileSize size) {
    switch (size) {
      case BentoTileSize.large:
        return 220;
      case BentoTileSize.medium:
        return 100;
      case BentoTileSize.small:
        return 140;
    }
  }
}

class _TileData {
  final Deck deck;
  final BentoTileSize size;

  _TileData({required this.deck, required this.size});
}
