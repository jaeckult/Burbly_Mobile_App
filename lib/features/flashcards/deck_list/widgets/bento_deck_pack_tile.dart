import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/models/deck_pack.dart';
import '../../../../core/animations/animated_wrappers.dart';

/// A tile for displaying a deck pack in the Bento grid.
/// Shows pack name, deck count, and allows expanding to see decks.
class BentoDeckPackTile extends StatelessWidget {
  final DeckPack deckPack;
  final int deckCount;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const BentoDeckPackTile({
    super.key,
    required this.deckPack,
    required this.deckCount,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final packColor = Color(int.parse('0xFF${deckPack.coverColor}'));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get initials from deck pack name
    final words = deckPack.name.trim().split(RegExp(r'\s+'));
    final initials = words.length >= 2
        ? (words[0][0] + words[1][0]).toUpperCase()
        : deckPack.name.substring(0, deckPack.name.length >= 2 ? 2 : 1).toUpperCase();

    return PressFeedback(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              packColor.withOpacity(isDark ? 0.2 : 0.15),
              packColor.withOpacity(isDark ? 0.1 : 0.05),
            ],
          ),
          border: Border.all(
            color: packColor.withOpacity(isDark ? 0.4 : 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: packColor.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                right: -10,
                bottom: -10,
                child: Icon(
                  Icons.folder,
                  size: 80,
                  color: packColor.withOpacity(0.1),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon with initials
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [packColor, packColor.withOpacity(0.7)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: packColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Pack name
                    Text(
                      deckPack.name,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.grey[900],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Deck count
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: packColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.style,
                            size: 14,
                            color: packColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$deckCount ${deckCount == 1 ? 'deck' : 'decks'}',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: packColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
