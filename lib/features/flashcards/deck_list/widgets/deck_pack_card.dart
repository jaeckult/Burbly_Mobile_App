import 'package:flutter/material.dart';
import '../../../../core/models/deck.dart';
import '../../../../core/models/deck_pack.dart';
import 'deck_card.dart';

/// Optimized DeckPack card widget with const constructor
class DeckPackCard extends StatelessWidget {
  final DeckPack deckPack;
  final List<Deck> decks;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onOptions;
  final VoidCallback onCreateDeck;
  final Function(Deck) onOpenDeck;
  final Function(Deck) onDeleteDeck;
  final String Function(DateTime) formatDate;

  const DeckPackCard({
    super.key,
    required this.deckPack,
    required this.decks,
    required this.isExpanded,
    required this.onToggle,
    required this.onOptions,
    required this.onCreateDeck,
    required this.onOpenDeck,
    required this.onDeleteDeck,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    // Get initials from deck pack name
    List<String> words = deckPack.name.trim().split(RegExp(r'\s+'));
    String initials;
    if (words.length >= 2) {
      initials = (words[0][0] + words[1][0]).toUpperCase();
    } else {
      initials = deckPack.name.substring(0, deckPack.name.length >= 2 ? 2 : 1).toUpperCase();
    }

    final packColor = Color(int.parse('0xFF${deckPack.coverColor}'));

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.black.withOpacity(0.3)
                  : packColor.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
            if (Theme.of(context).brightness == Brightness.light)
              BoxShadow(
                color: packColor.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
          ],
          border: Border.all(
            color: isExpanded 
                ? packColor.withOpacity(0.4)
                : Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey[700]!
                    : packColor.withOpacity(0.15),
            width: isExpanded ? 2.5 : 1.5,
          ),
        ),
        child: Column(
          children: [
            // Deck Pack Header
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: Theme.of(context).brightness == Brightness.light
                      ? [
                          packColor.withOpacity(0.12),
                          packColor.withOpacity(0.06),
                          packColor.withOpacity(0.02),
                        ]
                      : [
                          packColor.withOpacity(0.1),
                          packColor.withOpacity(0.05),
                        ],
                  stops: Theme.of(context).brightness == Brightness.light
                      ? [0.0, 0.6, 1.0]
                      : null,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                leading: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        packColor,
                        packColor.darken(0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: packColor.withOpacity(0.15), // Reduced opacity for subtle effect
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  deckPack.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (deckPack.description.isNotEmpty) ...[
                      Text(
                        deckPack.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                    ],
                    Row(
                      children: [
                        Icon(
                          Icons.folder,
                          size: 16,
                          color: packColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${decks.length} ${decks.length == 1 ? 'deck' : 'decks'}',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: packColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isExpanded
                            ? (Theme.of(context).colorScheme.primary).withOpacity(0.1)
                            : Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[800]
                                : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: isExpanded
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).iconTheme.color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                      onPressed: onOptions,
                    ),
                  ],
                ),
                onTap: onToggle,
              ),
            ),
            
            // Expanded content
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: isExpanded
                  ? Container(
                      padding: const EdgeInsets.fromLTRB(40, 20, 20, 20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light
                            ? packColor.withOpacity(0.04)
                            : packColor.withOpacity(0.02),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        border: Border(
                          top: BorderSide(
                            color: packColor.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                      ),
                      child: _buildDeckPackDetails(context),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeckPackDetails(BuildContext context) {
    final Color baseColor = Color(int.parse('0xFF${deckPack.coverColor}'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (decks.isNotEmpty) ...[
          Column(
            children: decks.asMap().entries.map((entry) {
              final index = entry.key;
              final deck = entry.value;
              return Column(
                children: [
                  DeckCard(
                    deck: deck,
                    deckPack: deckPack,
                    onTap: () => onOpenDeck(deck),
                    onDelete: () => onDeleteDeck(deck),
                    formatDate: formatDate,
                  ),
                  if (index < decks.length - 1)
                    Divider(
                      color: baseColor.withOpacity(0.1),
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],

        // Add New Deck Button
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: Theme.of(context).brightness == Brightness.light
                  ? [
                      baseColor.withOpacity(0.15),
                      baseColor.withOpacity(0.08),
                      baseColor.withOpacity(0.03),
                    ]
                  : [
                      baseColor.withOpacity(0.1),
                      baseColor.withOpacity(0.05),
                    ],
              stops: Theme.of(context).brightness == Brightness.light
                  ? [0.0, 0.7, 1.0]
                  : null,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: baseColor.withOpacity(0.25),
              style: BorderStyle.solid,
              width: 1.5,
            ),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : null,
            boxShadow: [
              if (Theme.of(context).brightness == Brightness.light)
                BoxShadow(
                  color: baseColor.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onCreateDeck,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: baseColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add New Deck',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: baseColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

extension ColorExtension on Color {
  Color darken(double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
