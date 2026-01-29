import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/animations/animated_wrappers.dart';

/// Quick action button data
class QuickAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

/// A draggable bottom sheet with quick actions for the home screen.
/// Provides shortcuts to common actions without navigation.
class QuickActionsSheet extends StatefulWidget {
  final List<QuickAction> actions;
  final Widget? header;
  final ValueChanged<bool>? onExpansionChanged;
  final DraggableScrollableController? controller;

  const QuickActionsSheet({
    super.key,
    required this.actions,
    this.header,
    this.onExpansionChanged,
    this.controller,
  });

  /// Default quick actions for the home screen
  static List<QuickAction> defaultActions({
    required VoidCallback onMixedStudy,
    required VoidCallback onCalendar,
    required VoidCallback onBurblyAI,
  }) {
    return [
      QuickAction(
        title: 'Mixed Study',
        subtitle: 'Study from all your decks',
        icon: Icons.shuffle,
        color: Colors.purple,
        onTap: onMixedStudy,
      ),
      QuickAction(
        title: 'Your Calendar',
        subtitle: 'View your study schedule',
        icon: Icons.calendar_today,
        color: Colors.blue,
        onTap: onCalendar,
      ),
      QuickAction(
        title: 'Use Burbly AI',
        subtitle: 'Coming Soon',
        icon: Icons.auto_awesome,
        color: Colors.amber,
        onTap: onBurblyAI,
      ),
    ];
  }

  @override
  State<QuickActionsSheet> createState() => _QuickActionsSheetState();
}

class _QuickActionsSheetState extends State<QuickActionsSheet> {
  bool _isExpanded = false;
  double _lastSize = 0.12;

  @override
  void initState() {
    super.initState();
    // Listen to controller changes if provided
    widget.controller?.addListener(_onSheetChanged);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onSheetChanged);
    super.dispose();
  }

  void _onSheetChanged() {
    if (widget.controller != null && widget.controller!.isAttached) {
      final currentSize = widget.controller!.size;
      
      // Only update if the size changed significantly (user dragged)
      if ((currentSize - _lastSize).abs() > 0.05) {
        _lastSize = currentSize;
        final shouldBeExpanded = currentSize > 0.2;
        
        if (shouldBeExpanded != _isExpanded) {
          setState(() => _isExpanded = shouldBeExpanded);
          widget.onExpansionChanged?.call(_isExpanded);
        }
      }
    }
  }

  void _toggleExpansion() {
    final newExpandedState = !_isExpanded;
    
    // Update state first
    setState(() => _isExpanded = newExpandedState);
    widget.onExpansionChanged?.call(_isExpanded);
    
    // Then animate controller if provided
    if (widget.controller != null && widget.controller!.isAttached) {
      final targetSize = newExpandedState ? 0.45 : 0.12;
      _lastSize = targetSize;
      widget.controller!.animateTo(
        targetSize,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _collapse() {
    if (_isExpanded) {
      setState(() => _isExpanded = false);
      widget.onExpansionChanged?.call(false);
      
      if (widget.controller != null && widget.controller!.isAttached) {
        _lastSize = 0.12;
        widget.controller!.animateTo(
          0.12,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      controller: widget.controller,
      initialChildSize: 0.12,
      minChildSize: 0.08,
      maxChildSize: 0.45,
      snap: true,
      snapSizes: const [0.12, 0.45],
      builder: (context, scrollController) {

        return Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          // We attach the scrollController here so the sheet can actually move
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const ClampingScrollPhysics(), // Allows sheet to be dragged
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Grip indicator and header - clickable to expand
                GestureDetector(
                  onTap: _toggleExpansion,
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Grip indicator
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 12, bottom: 8),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.flash_on,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Quick Actions',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.grey[900],
                              ),
                            ),
                            const Spacer(),
                            AnimatedRotation(
                              turns: _isExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 300),
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const Divider(height: 1),
                    ],
                  ),
                ),
                
                // Action items - always rendered for sheet to work properly
                AnimatedOpacity(
                  opacity: _isExpanded ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...widget.actions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final action = entry.value;
                        return FadeInSlideUp(
                          delay: Duration(milliseconds: 50 * index),
                          child: _QuickActionTile(
                            action: action,
                            onTap: () {
                              action.onTap();
                              _collapse();
                            },
                          ),
                        );
                      }),
                      
                      if (widget.header != null) widget.header!,
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final QuickAction action;
  final VoidCallback? onTap;

  const _QuickActionTile({required this.action, this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressFeedback(
      onTap: onTap ?? action.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: action.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: action.color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [action.color, action.color.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: action.color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(action.icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    action.subtitle,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: action.color.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}
