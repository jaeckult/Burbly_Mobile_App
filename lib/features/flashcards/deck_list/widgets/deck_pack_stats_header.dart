import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Premium stats header with quick filters for the deck pack list
/// Features:
/// - Animated stat cards showing key metrics
/// - Filter chips for quick filtering
/// - Smooth entrance animations
class DeckPackStatsHeader extends StatelessWidget {
  final int totalPacks;
  final int totalDecks;
  final int totalCards;
  final int decksToReview;
  final int currentStreak;
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const DeckPackStatsHeader({
    super.key,
    required this.totalPacks,
    required this.totalDecks,
    required this.totalCards,
    required this.decksToReview,
    required this.currentStreak,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stats Row
          Row(
            children: [
              _buildStatCard(
                context,
                icon: Icons.folder_rounded,
                value: '$totalPacks',
                label: 'Packs',
                color: Colors.blue,
                delay: 0,
              ),
              const SizedBox(width: 8),
              _buildStatCard(
                context,
                icon: Icons.layers_rounded,
                value: '$totalDecks',
                label: 'Decks',
                color: Colors.purple,
                delay: 50,
              ),
              const SizedBox(width: 8),
              _buildStatCard(
                context,
                icon: Icons.style_rounded,
                value: _formatNumber(totalCards),
                label: 'Cards',
                color: Colors.teal,
                delay: 100,
              ),
              const SizedBox(width: 8),
              _buildStatCard(
                context,
                icon: Icons.notifications_active_rounded,
                value: '$decksToReview',
                label: 'Review',
                color: Colors.orange,
                isHighlighted: decksToReview > 0,
                delay: 150,
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          // Filter Chips
          SizedBox(
            height: 28,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip(context, 'All', Icons.apps_rounded),
                const SizedBox(width: 6),
                _buildFilterChip(context, 'Review', Icons.schedule_rounded, 
                    badgeCount: decksToReview > 0 ? decksToReview : null),
                const SizedBox(width: 6),
                _buildFilterChip(context, 'Recent', Icons.history_rounded),
                const SizedBox(width: 6),
                _buildFilterChip(context, 'Favorites', Icons.star_rounded),
                const SizedBox(width: 6),
                _buildFilterChip(context, 'Large', Icons.storage_rounded),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    bool isHighlighted = false,
    int delay = 0,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isHighlighted
                ? [color.withOpacity(0.2), color.withOpacity(0.1)]
                : [
                    isDark ? Colors.grey[850]! : Colors.grey[50]!,
                    isDark ? Colors.grey[900]! : Colors.grey[100]!,
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isHighlighted 
                ? color.withOpacity(0.4) 
                : isDark ? Colors.grey[800]! : Colors.grey[200]!,
            width: isHighlighted ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: color,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isHighlighted ? color : (isDark ? Colors.white : Colors.grey[800]),
                height: 1.1,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
                height: 1.2,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(
        delay: Duration(milliseconds: delay),
        duration: 300.ms,
      ).scale(
        begin: const Offset(0.8, 0.8),
        end: const Offset(1, 1),
        delay: Duration(milliseconds: delay),
        duration: 300.ms,
        curve: Curves.easeOutBack,
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, IconData icon, {int? badgeCount}) {
    final isSelected = selectedFilter == label;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onFilterChanged(label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected 
              ? primaryColor.withOpacity(0.15)
              : isDark ? Colors.grey[850] : Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected 
                ? primaryColor.withOpacity(0.5)
                : isDark ? Colors.grey[700]! : Colors.grey[300]!,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: isSelected ? primaryColor : Colors.grey[500],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? primaryColor : Colors.grey[600],
              ),
            ),
            if (badgeCount != null) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return '$number';
  }
}
