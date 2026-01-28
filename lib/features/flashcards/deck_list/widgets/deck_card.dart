import 'package:flutter/material.dart';
import '../../../../core/models/deck.dart';
import '../../../../core/models/deck_pack.dart';
import '../../../../core/utils/navigation_helper.dart';

/// Optimized Deck card widget with const constructor
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
    
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.black.withOpacity(0.2)
                  : deckColor.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            if (Theme.of(context).brightness == Brightness.light)
              BoxShadow(
                color: deckColor.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
          ],
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.grey[700]!
                : deckColor.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Deck Icon with Hero Animation
                  HeroWrapper(
                    tag: 'deck_icon_${deck.id}',
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(int.parse('0xFF${deck.coverColor ?? '2196F3'}')),
                            Color(int.parse('0xFF${deck.coverColor ?? '1976D2'}')),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Color(int.parse('0xFF${deck.coverColor ?? '2196F3'}')).withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Deck Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deck.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (deck.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            deck.description,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.style, size: 14, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${deck.cardCount} ${deck.cardCount == 1 ? 'card' : 'cards'}',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                formatDate(deck.updatedAt),
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: Colors.grey[500],
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Action Buttons
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: onDelete,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.red.withOpacity(0.2)
                                : Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
