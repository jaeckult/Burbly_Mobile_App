import 'package:flutter/material.dart';
import '../../../../core/models/deck.dart';
import '../../../../core/models/deck_pack.dart';
import '../../../../core/utils/navigation_helper.dart';

/// Optimized compact Deck card widget with improved visual hierarchy
/// - 35% smaller overall size
/// - Clear text hierarchy with no overflow
/// - Compact icon and action buttons
class DeckCard extends StatelessWidget {
  final Deck deck;
  final DeckPack deckPack;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final String Function(DateTime) formatDate;

  const DeckCard({
    super.key,
    required this.deck,
    required this.deckPack,
    required this.onTap,
    required this.onDelete,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final deckColor = Color(int.parse('0xFF${deck.coverColor ?? '2196F3'}'));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Check if deck needs review
    final needsReview = (deck.deckIsReviewNow == true) || (deck.deckIsOverdue == true);
    
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: isDark 
              ? Colors.grey[850] 
              : Colors.white,
          borderRadius: BorderRadius.circular(10), // Reduced from 16
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? Colors.black.withOpacity(0.15)
                  : deckColor.withOpacity(0.04),
              blurRadius: 6, // Reduced from 12
              offset: const Offset(0, 2), // Reduced from 4
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: needsReview
                ? Colors.orange.withOpacity(0.5)
                : isDark 
                    ? Colors.grey[700]!
                    : deckColor.withOpacity(0.12),
            width: needsReview ? 1.5 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Reduced from 16
              child: Row(
                children: [
                  // Deck Icon - compact with Hero Animation
                  HeroWrapper(
                    tag: 'deck_icon_${deck.id}',
                    child: Container(
                      width: 32, // Reduced from 48
                      height: 32, // Reduced from 48
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            deckColor,
                            deckColor.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8), // Reduced from 12
                        boxShadow: [
                          BoxShadow(
                            color: deckColor.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 16, // Reduced from 24
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 10), // Reduced from 16
                  
                  // Deck Info - compact with proper overflow handling
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title with review indicator
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                deck.name,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13, // Explicit size
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (needsReview) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Review',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange[700],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        
                        const SizedBox(height: 3),
                        
                        // Stats row - compact
                        Row(
                          children: [
                            // Card count
                            _buildStatChip(
                              context,
                              Icons.style_rounded,
                              '${deck.cardCount}',
                              deckColor,
                            ),
                            const SizedBox(width: 8),
                            // Date
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 10,
                                    color: Colors.grey[500],
                                  ),
                                  const SizedBox(width: 2),
                                  Flexible(
                                    child: Text(
                                      formatDate(deck.updatedAt),
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.grey[500],
                                        height: 1.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 6),
                  
                  // Delete button - compact
                  GestureDetector(
                    onTap: onDelete,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.all(6), // Reduced from 8
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.red.withOpacity(0.15)
                            : Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6), // Reduced from 8
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red[400],
                        size: 14, // Reduced from 18
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 10,
          color: color.withOpacity(0.7),
        ),
        const SizedBox(width: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color.withOpacity(0.8),
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
