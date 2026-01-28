import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/models/deck.dart';
import '../../../../core/models/deck_pack.dart';
import '../../../../core/animations/animated_wrappers.dart';

/// Tile size variants for the Bento grid
enum BentoTileSize {
  small,  // 1x1 - idle decks
  medium, // 2x1 - recently studied  
  large,  // 2x2 - active reviews
}

/// A variable-size tile for the Bento grid dashboard.
/// Size is determined by deck activity level.
class BentoDeckTile extends StatelessWidget {
  final Deck deck;
  final DeckPack? deckPack;
  final BentoTileSize size;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const BentoDeckTile({
    super.key,
    required this.deck,
    this.deckPack,
    required this.size,
    required this.onTap,
    this.onLongPress,
  });

  /// Factory to automatically determine tile size based on deck state
  factory BentoDeckTile.auto({
    Key? key,
    required Deck deck,
    DeckPack? deckPack,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) {
    final size = _determineTileSize(deck);
    return BentoDeckTile(
      key: key,
      deck: deck,
      deckPack: deckPack,
      size: size,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  static BentoTileSize _determineTileSize(Deck deck) {
    // Large: Has scheduled review or is overdue
    if (deck.deckIsOverdue == true || deck.deckIsReviewNow == true) {
      return BentoTileSize.large;
    }
    // Medium: Recently updated (within 3 days)
    final daysSinceUpdate = DateTime.now().difference(deck.updatedAt).inDays;
    if (daysSinceUpdate <= 3 && deck.cardCount > 0) {
      return BentoTileSize.medium;
    }
    // Small: Everything else
    return BentoTileSize.small;
  }

  @override
  Widget build(BuildContext context) {
    final deckColor = Color(int.parse('0xFF${deck.coverColor ?? '2196F3'}'));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PressFeedback(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    deckColor.withOpacity(0.15),
                    deckColor.withOpacity(0.08),
                  ]
                : [
                    deckColor.withOpacity(0.12),
                    deckColor.withOpacity(0.04),
                    Colors.white.withOpacity(0.9),
                  ],
            stops: isDark ? null : [0.0, 0.4, 1.0],
          ),
          border: Border.all(
            color: deckColor.withOpacity(isDark ? 0.3 : 0.2),
            width: 1.5,
          ),
          boxShadow: [
            // Outer shadow
            BoxShadow(
              color: deckColor.withOpacity(isDark ? 0.15 : 0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
            // Inner glow effect (glassmorphism)
            if (!isDark)
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 1,
                spreadRadius: -1,
                offset: const Offset(0, -1),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  Icons.school,
                  size: size == BentoTileSize.large ? 100 : 60,
                  color: deckColor.withOpacity(0.08),
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.all(size == BentoTileSize.small ? 12 : 16),
                child: _buildContent(context, deckColor, isDark),
              ),
              // Progress bar at bottom
              if (deck.cardCount > 0)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildProgressBar(context, deckColor),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color deckColor, bool isDark) {
    switch (size) {
      case BentoTileSize.large:
        return _buildLargeContent(context, deckColor, isDark);
      case BentoTileSize.medium:
        return _buildMediumContent(context, deckColor, isDark);
      case BentoTileSize.small:
        return _buildSmallContent(context, deckColor, isDark);
    }
  }

  Widget _buildLargeContent(BuildContext context, Color deckColor, bool isDark) {
    final masteryPercent = _calculateMastery();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with icon
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [deckColor, deckColor.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: deckColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deck.name,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.grey[900],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (deckPack != null)
                    Text(
                      deckPack!.name,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: deckColor,
                      ),
                    ),
                ],
              ),
            ),
            // Streak indicator
            if (_hasStreak())
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      '3',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        
        const Spacer(),
        
        // Stats row
        Row(
          children: [
            _buildStatChip(
              context,
              '${masteryPercent.toInt()}%',
              'Mastery',
              Icons.trending_up,
              deckColor,
            ),
            const SizedBox(width: 12),
            _buildStatChip(
              context,
              '${deck.cardCount}',
              'Cards',
              Icons.style,
              Colors.grey,
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Next review time
        if (deck.scheduledReviewTime != null || deck.deckIsOverdue == true)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: deck.deckIsOverdue == true
                  ? Colors.red.withOpacity(0.15)
                  : deckColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  deck.deckIsOverdue == true ? Icons.warning : Icons.schedule,
                  size: 14,
                  color: deck.deckIsOverdue == true ? Colors.red : deckColor,
                ),
                const SizedBox(width: 6),
                Text(
                  deck.deckIsOverdue == true
                      ? 'Review Overdue!'
                      : 'Due: ${_formatNextReview()}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: deck.deckIsOverdue == true ? Colors.red : deckColor,
                  ),
                ),
              ],
            ),
          ),
        
        const SizedBox(height: 16), // Space for progress bar
      ],
    );
  }

  Widget _buildMediumContent(BuildContext context, Color deckColor, bool isDark) {
    return Row(
      children: [
        // Icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [deckColor, deckColor.withOpacity(0.7)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: deckColor.withOpacity(0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.school, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 14),
        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                deck.name,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.grey[900],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.style, size: 12, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    '${deck.cardCount} cards',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    _formatLastStudied(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Streak if applicable
        if (_hasStreak())
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Text('🔥', style: TextStyle(fontSize: 18)),
          ),
      ],
    );
  }

  Widget _buildSmallContent(BuildContext context, Color deckColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [deckColor, deckColor.withOpacity(0.7)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.school, color: Colors.white, size: 18),
        ),
        const SizedBox(height: 10),
        Text(
          deck.name,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.grey[900],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const Spacer(),
        Text(
          '${deck.cardCount} cards',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            color: deckColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8), // Space for progress bar
      ],
    );
  }

  Widget _buildStatChip(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, Color deckColor) {
    final mastery = _calculateMastery() / 100.0;
    
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: deckColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: mastery.clamp(0.05, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [deckColor, deckColor.withOpacity(0.7)],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
      ),
    );
  }

  double _calculateMastery() {
    // Simple mastery calculation based on reviewed state
    if (deck.deckIsReviewed == true) return 85.0;
    if (deck.deckIsOverdue == true) return 30.0;
    if (deck.cardCount == 0) return 0.0;
    return 50.0; // Default
  }

  bool _hasStreak() {
    // Simplified streak detection - study 3+ days in a row
    final daysSinceUpdate = DateTime.now().difference(deck.updatedAt).inDays;
    return daysSinceUpdate <= 1 && deck.cardCount > 5;
  }

  String _formatLastStudied() {
    final diff = DateTime.now().difference(deck.updatedAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${diff.inDays ~/ 7}w ago';
  }

  String _formatNextReview() {
    if (deck.scheduledReviewTime == null) return 'Soon';
    final diff = deck.scheduledReviewTime!.difference(DateTime.now());
    if (diff.isNegative) return 'Now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

/// Helper extension to get cross axis cell count based on tile size
extension BentoTileSizeExtension on BentoTileSize {
  int get crossAxisCellCount {
    switch (this) {
      case BentoTileSize.large:
        return 2;
      case BentoTileSize.medium:
        return 2;
      case BentoTileSize.small:
        return 1;
    }
  }

  int get mainAxisCellCount {
    switch (this) {
      case BentoTileSize.large:
        return 2;
      case BentoTileSize.medium:
        return 1;
      case BentoTileSize.small:
        return 1;
    }
  }
}
