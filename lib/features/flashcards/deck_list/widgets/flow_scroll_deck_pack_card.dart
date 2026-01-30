import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/deck.dart';
import '../../../../core/models/deck_pack.dart';
import '../../../../core/models/flashcard.dart';
import '../controllers/flow_scroll_controller.dart';

/// Enhanced deck pack card that supports Flow-Scroll Review mode
/// In flow mode: scales up, shows flashcard content, reveals answers on scroll
class FlowScrollDeckPackCard extends StatefulWidget {
  final DeckPack deckPack;
  final List<Deck> decks;
  final bool isActive;
  final double scrollProgress;
  final Flashcard? currentCard;
  final VoidCallback onTap;
  final Widget normalContent;

  const FlowScrollDeckPackCard({
    super.key,
    required this.deckPack,
    required this.decks,
    required this.isActive,
    required this.scrollProgress,
    this.currentCard,
    required this.onTap,
    required this.normalContent,
  });

  @override
  State<FlowScrollDeckPackCard> createState() => _FlowScrollDeckPackCardState();
}

class _FlowScrollDeckPackCardState extends State<FlowScrollDeckPackCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(FlowScrollDeckPackCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _scaleController.forward();
        HapticFeedback.mediumImpact();
      } else {
        _scaleController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final packColor = Color(int.parse('0xFF${widget.deckPack.coverColor}'));

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        final scale = 1.0 + (_scaleAnimation.value * 0.1); // 10% scale increase
        final opacity = widget.isActive ? 1.0 : 0.5; // Non-active cards are semi-transparent

        return Transform.scale(
          scale: scale,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: opacity,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: widget.isActive && widget.currentCard != null
                    ? _buildFlowModeCard(packColor)
                    : widget.normalContent,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build the card in flow mode showing flashcard content
  Widget _buildFlowModeCard(Color packColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = widget.currentCard!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            packColor.withOpacity(0.95),
            packColor.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: packColor.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Deck pack name header
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.deckPack.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Tap to exit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Question
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QUESTION',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  card.question,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Answer - slides up based on scroll progress
          ClipRect(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              height: widget.scrollProgress >= 0.2 ? null : 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: widget.scrollProgress.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(
                    0,
                    (1.0 - widget.scrollProgress.clamp(0.0, 1.0)) * 20,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ANSWER',
                          style: TextStyle(
                            color: packColor.withOpacity(0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          card.answer,
                          style: TextStyle(
                            color: packColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Scroll hint
          if (widget.scrollProgress < 0.2)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_downward_rounded,
                    color: Colors.white.withOpacity(0.5),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Scroll to reveal answer',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
