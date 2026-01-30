import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/models/deck.dart';
import '../../../../core/models/deck_pack.dart';
import 'deck_card.dart';

/// Enhanced DeckPack card with improved visual hierarchy
/// Features:
/// - 35% smaller card size with compact layout
/// - Clear visual hierarchy with proper spacing
/// - Red dot badge when decks need review
/// - Smooth notification banner with slide/fade animations
/// - Staggered entrance effects
class DeckPackNotificationCard extends StatefulWidget {
  final DeckPack deckPack;
  final List<Deck> decks;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onOptions;
  final VoidCallback onCreateDeck;
  final Function(Deck) onOpenDeck;
  final Function(Deck) onDeleteDeck;
  final String Function(DateTime) formatDate;
  final int listIndex;
  final bool isCompactMode;

  const DeckPackNotificationCard({
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
    this.listIndex = 0,
    this.isCompactMode = false,
  });

  @override
  State<DeckPackNotificationCard> createState() => _DeckPackNotificationCardState();
}

class _DeckPackNotificationCardState extends State<DeckPackNotificationCard>
    with SingleTickerProviderStateMixin {
  Timer? _autoExpandTimer;
  bool _showNotification = false;
  late AnimationController _notificationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _notificationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _notificationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _notificationController,
      curve: Curves.easeOut,
    ));
  }

  void _showNotificationBanner() {
    if (!mounted) return;
    
    setState(() => _showNotification = true);
    _notificationController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _notificationController.reverse().then((_) {
          if (mounted) {
            setState(() => _showNotification = false);
          }
        });
      }
    });
  }

  void _onBadgeTap() {
    _showNotificationBanner();
  }

  void _onNotificationTap() {
    final deckToReview = widget.decks.firstWhere(
      (deck) => (deck.deckIsReviewNow == true) || (deck.deckIsOverdue == true),
      orElse: () => widget.decks.first,
    );
    widget.onOpenDeck(deckToReview);
  }

  @override
  void dispose() {
    _autoExpandTimer?.cancel();
    _notificationController.dispose();
    super.dispose();
  }

  int get _decksToReview => _calculateDecksToReview(widget.decks);

  int _calculateDecksToReview(List<Deck> decks) {
    return decks.where((deck) {
      return (deck.deckIsReviewNow == true) || (deck.deckIsOverdue == true);
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    // Get initials from deck pack name
    List<String> words = widget.deckPack.name.trim().split(RegExp(r'\s+'));
    String initials;
    if (words.length >= 2) {
      initials = (words[0][0] + words[1][0]).toUpperCase();
    } else {
      initials = widget.deckPack.name.substring(0, widget.deckPack.name.length >= 2 ? 2 : 1).toUpperCase();
    }

    final packColor = Color(int.parse('0xFF${widget.deckPack.coverColor}'));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12), // Reduced from 20
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Notification banner - positioned above card
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              height: _showNotification && _decksToReview > 0 ? null : 0,
              child: _showNotification && _decksToReview > 0
                  ? SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildNotificationBanner(context, packColor),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // Main card - compact design
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14), // Reduced from 20
                    boxShadow: [
                      BoxShadow(
                        color: isDark 
                            ? Colors.black.withOpacity(0.25)
                            : packColor.withOpacity(0.06),
                        blurRadius: 10, // Reduced from 16
                        offset: const Offset(0, 4), // Reduced from 6
                        spreadRadius: 0,
                      ),
                    ],
                    border: Border.all(
                      color: widget.isExpanded 
                          ? packColor.withOpacity(0.5)
                          : isDark 
                              ? Colors.grey[800]!
                              : packColor.withOpacity(0.12),
                      width: widget.isExpanded ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Deck Pack Header - COMPACT
                      _buildCompactHeader(context, packColor, initials, isDark),
                      
                      // Expanded content
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        child: widget.isExpanded
                            ? Container(
                                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12), // Reduced padding
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? packColor.withOpacity(0.03)
                                      : packColor.withOpacity(0.02),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(14),
                                    bottomRight: Radius.circular(14),
                                  ),
                                  border: Border(
                                    top: BorderSide(
                                      color: packColor.withOpacity(0.08),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: _buildDeckPackDetails(context, packColor),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),

                // Orange dot badge indicator
                if (_decksToReview > 0)
                  Positioned(
                    top: -3,
                    right: -3,
                    child: GestureDetector(
                      onTap: _onBadgeTap,
                      child: _buildOrangeBadge(),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
      duration: 350.ms,
      delay: (widget.listIndex * 80).ms,
    ).slideY(
      begin: 0.1,
      end: 0,
      duration: 350.ms,
      delay: (widget.listIndex * 80).ms,
      curve: Curves.easeOutCubic,
    );
  }

  /// Compact header with better visual hierarchy
  Widget _buildCompactHeader(BuildContext context, Color packColor, String initials, bool isDark) {
    return InkWell(
      onTap: widget.onToggle,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(14),
        topRight: Radius.circular(14),
      ),
      child: Container(
        padding: widget.isCompactMode 
            ? const EdgeInsets.symmetric(horizontal: 4, vertical: 10)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    packColor.withOpacity(0.08),
                    packColor.withOpacity(0.03),
                  ]
                : [
                    packColor.withOpacity(0.08),
                    packColor.withOpacity(0.02),
                  ],
          ),
        ),
        child: Row(
          children: [
            // Compact avatar (Always visible)
            Container(
              width: 36, // Reduced from 56
              height: 36, // Reduced from 56
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    packColor,
                    packColor.darken(0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: packColor.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13, // Reduced from 20
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 10), // Reduced from 16
            
            // Title and info - COMPACT (Hidden in compact shrinking mode)
            if (!widget.isCompactMode)
              Expanded(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: widget.isCompactMode ? 0.0 : 1.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.deckPack.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 14, // Explicit smaller size
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      // Deck count badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: packColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.layers_rounded,
                                  size: 10,
                                  color: packColor,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${widget.decks.length} ${widget.decks.length == 1 ? 'deck' : 'decks'}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: packColor,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (widget.deckPack.description.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                widget.deckPack.description,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[500],
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            
            // Trailing actions - compact (Hidden in compact shrinking mode)
            if (!widget.isCompactMode)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: widget.isCompactMode ? 0.0 : 1.0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5), // Reduced from 8
                      decoration: BoxDecoration(
                        color: widget.isExpanded
                            ? packColor.withOpacity(0.15)
                            : isDark
                                ? Colors.grey[800]
                                : Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        widget.isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                        color: widget.isExpanded
                            ? packColor
                            : Colors.grey[600],
                        size: 16, // Reduced from 20
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onOptions,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        child: Icon(
                          Icons.more_vert_rounded,
                          color: Colors.grey[500],
                          size: 16, // Reduced from default
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationBanner(BuildContext context, Color packColor) {
    return GestureDetector(
      onTap: _onNotificationTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Reduced padding
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange.shade400,
              Colors.orange.shade600,
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                color: Colors.white,
                size: 12, // Reduced from 18
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _decksToReview == 1
                    ? '1 deck needs review'
                    : '$_decksToReview decks need review',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11, // Reduced from 14
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 10, // Reduced from 14
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrangeBadge() {
    return Container(
      width: 18, // Reduced from 24
      height: 18, // Reduced from 24
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade400,
            Colors.orange.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.4),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: Colors.white,
          width: 1.5, // Reduced from 2
        ),
      ),
      child: Center(
        child: Text(
          _decksToReview > 9 ? '9+' : '$_decksToReview',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8, // Reduced from 10
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ).animate(
      onPlay: (controller) => controller.repeat(reverse: true),
    ).scale(
      begin: const Offset(0.95, 0.95),
      end: const Offset(1.05, 1.05),
      duration: 1500.ms,
      curve: Curves.easeInOut,
    );
  }

  Widget _buildDeckPackDetails(BuildContext context, Color baseColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.decks.isNotEmpty) ...[
          ...widget.decks.asMap().entries.map((entry) {
            final index = entry.key;
            final deck = entry.value;
            return Column(
              children: [
                DeckCard(
                  deck: deck,
                  deckPack: widget.deckPack,
                  onTap: () => widget.onOpenDeck(deck),
                  onDelete: () => widget.onDeleteDeck(deck),
                  formatDate: widget.formatDate,
                ),
                if (index < widget.decks.length - 1)
                  const SizedBox(height: 6), // Simple spacing instead of divider
              ],
            );
          }),
          const SizedBox(height: 8), // Reduced from 16
        ],

        // Add New Deck Button - compact
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: baseColor.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: baseColor.withOpacity(0.15),
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onCreateDeck,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12), // Reduced
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      color: baseColor,
                      size: 16, // Reduced from 20
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Add Deck',
                      style: TextStyle(
                        color: baseColor,
                        fontSize: 12, // Reduced
                        fontWeight: FontWeight.w600,
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
