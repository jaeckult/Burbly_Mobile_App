import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Minimized deck pack view shown when AI panel is expanded
/// Shows only circular initials in a vertical strip
class DeckPackInitialsStrip extends StatelessWidget {
  final List<DeckPack> deckPacks;
  final Function(DeckPack) onDeckPackTap;
  
  const DeckPackInitialsStrip({
    super.key,
    required this.deckPacks,
    required this.onDeckPackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: deckPacks.length,
        itemBuilder: (context, index) {
          final deckPack = deckPacks[index];
          return _buildDeckInitialCircle(context, deckPack);
        },
      ),
    );
  }

  Widget _buildDeckInitialCircle(BuildContext context, DeckPack deckPack) {
    // Get initials (first 2 letters of deck pack name)
    final initials = _getInitials(deckPack.name);
    
    // Color based on deck pack name hash
    final color = _getColorForDeckPack(deckPack.name);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onDeckPackTap(deckPack),
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.8),
                  color,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '??';
    
    final words = name.trim().split(' ');
    if (words.length >= 2) {
      // Take first letter of first two words
      return (words[0][0] + words[1][0]).toUpperCase();
    } else {
      // Take first two letters of single word
      return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
    }
  }

  Color _getColorForDeckPack(String name) {
    // Generate consistent color based on name hash
    final hash = name.hashCode;
    final colors = [
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFEC4899), // Pink
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF10B981), // Green
      const Color(0xFF6366F1), // Indigo
      const Color(0xFFEF4444), // Red
      const Color(0xFF14B8A6), // Teal
    ];
    
    return colors[hash.abs() % colors.length];
  }
}
