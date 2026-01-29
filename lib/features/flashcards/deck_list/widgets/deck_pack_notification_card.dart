import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/models/deck.dart';
import '../../../../core/models/deck_pack.dart';
import 'deck_card.dart';

/// Enhanced DeckPack card with inline notification system
/// Features:
/// - Red dot badge when decks need review
/// - Auto-expansion every 10 seconds
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
    
    // Initialize notification animation controller
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

    // Start auto-expansion timer if there are decks to review
    // if (_decksToReview > 0) {
    //   _startAutoExpandTimer();
    // }
  }

//   void _startAutoExpandTimer() {
//     _autoExpandTimer?.cancel();
//     _autoExpandTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
//       if (mounted && !widget.isExpanded) {
//         _showNotificationBanner();
//       }
//     });
//   }

  void _showNotificationBanner() {
    if (!mounted) return;
    
    setState(() => _showNotification = true);
    _notificationController.forward();

    // Reset timer when notification is shown
    // _startAutoExpandTimer();

    // Hide notification after 3 seconds
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
    // Show notification banner
    _showNotificationBanner();
  }

  void _onNotificationTap() {
    // Navigate to first deck that needs review
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

  @override
  void didUpdateWidget(DeckPackNotificationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Restart timer if review count changed
    // if (_decksToReview != _calculateDecksToReview(oldWidget.decks)) {
    //   if (_decksToReview > 0) {
    //     _startAutoExpandTimer();
    //   } else {
    //     _autoExpandTimer?.cancel();
    //   }
    // }
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

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
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

            // Main card - fixed position
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
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
                  color: widget.isExpanded 
                      ? packColor.withOpacity(0.4)
                      : Theme.of(context).brightness == Brightness.dark 
                          ? Colors.grey[700]!
                          : packColor.withOpacity(0.15),
                  width: widget.isExpanded ? 2.5 : 1.5,
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
                                  color: packColor.withOpacity(0.15),
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
                            widget.deckPack.name,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.deckPack.description.isNotEmpty) ...[
                                Text(
                                  widget.deckPack.description,
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
                                    '${widget.decks.length} ${widget.decks.length == 1 ? 'deck' : 'decks'}',
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
                                  color: widget.isExpanded
                                      ? (Theme.of(context).colorScheme.primary).withOpacity(0.1)
                                      : Theme.of(context).brightness == Brightness.dark
                                          ? Colors.grey[800]
                                          : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  widget.isExpanded ? Icons.expand_less : Icons.expand_more,
                                  color: widget.isExpanded
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).iconTheme.color,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                                onPressed: widget.onOptions,
                              ),
                            ],
                          ),
                          onTap: widget.onToggle,
                        ),
                      ),
                      
                      // Expanded content
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        child: widget.isExpanded
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
                    top: -4,
                    right: -4,
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
      duration: 400.ms,
      delay: (widget.listIndex * 100).ms,
    ).scale(
      begin: const Offset(0.95, 0.95),
      end: const Offset(1.0, 1.0),
      duration: 400.ms,
      delay: (widget.listIndex * 100).ms,
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildNotificationBanner(BuildContext context, Color packColor) {
    return GestureDetector(
      onTap: _onNotificationTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange.shade400.withOpacity(0.9),
              Colors.orange.shade600.withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _decksToReview == 1
                    ? '1 deck needs review'
                    : '$_decksToReview decks need review',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrangeBadge() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade400,
            Colors.orange.shade700,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          _decksToReview > 9 ? '9+' : '$_decksToReview',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ).animate(
      onPlay: (controller) => controller.repeat(reverse: true),
    ).scale(
      begin: const Offset(0.9, 0.9),
      end: const Offset(1.1, 1.1),
      duration: 2000.ms,
      curve: Curves.easeInOut,
    );
  }

  Widget _buildDeckPackDetails(BuildContext context, Color baseColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.decks.isNotEmpty) ...[
          Column(
            children: widget.decks.asMap().entries.map((entry) {
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
              onTap: widget.onCreateDeck,
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
