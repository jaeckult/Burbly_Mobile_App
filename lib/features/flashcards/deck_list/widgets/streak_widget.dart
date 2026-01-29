import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/services/background_service.dart';

/// A beautiful streak widget inspired by Duolingo's design
/// Shows current study streak with flame icon and smooth animations
class StreakWidget extends StatefulWidget {
  final VoidCallback? onTap;
  
  // Global key to allow refreshing from anywhere
  static final GlobalKey<_StreakWidgetState> globalKey = GlobalKey<_StreakWidgetState>();

  StreakWidget({
    this.onTap,
  }) : super(key: globalKey);
  
  /// Refresh the streak widget from anywhere in the app
  static void refresh() {
    globalKey.currentState?._loadStreak();
  }

  @override
  State<StreakWidget> createState() => _StreakWidgetState();
}

class _StreakWidgetState extends State<StreakWidget> {
  final BackgroundService _backgroundService = BackgroundService();
  int _currentStreak = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize with current value
    _currentStreak = _backgroundService.streakNotifier.value;
    // Load fresh value to be sure
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    final streak = await _backgroundService.getCurrentStreak();
    if (mounted) {
      // Update notifier if needed (will trigger listener in build)
      if (_backgroundService.streakNotifier.value != streak) {
        _backgroundService.streakNotifier.value = streak;
      }
      setState(() {
        _currentStreak = streak;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        width: 60,
        height: 36,
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return ValueListenableBuilder<int>(
      valueListenable: _backgroundService.streakNotifier,
      builder: (context, streakValue, child) {
        // Use the notifier value, but fallback to local state if needed
        final displayStreak = streakValue > 0 ? streakValue : _currentStreak;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final hasStreak = displayStreak > 0;

        return GestureDetector(
          onTap: widget.onTap ?? () => _showStreakDialog(displayStreak),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: hasStreak
                  ? LinearGradient(
                      colors: [
                        Colors.orange.shade400,
                        Colors.deepOrange.shade500,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [
                        isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                        isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                      ],
                    ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: hasStreak
                  ? [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Flame icon
                Icon(
                  hasStreak ? Icons.local_fire_department : Icons.local_fire_department_outlined,
                  color: hasStreak ? Colors.white : Colors.grey.shade600,
                  size: 20,
                )
                    .animate(
                      onPlay: (controller) => hasStreak ? controller.repeat(reverse: true) : null,
                    )
                    .scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.1, 1.1),
                      duration: hasStreak ? 1500.ms : 0.ms,
                      curve: Curves.easeInOut,
                    )
                    .then()
                    .shimmer(
                      duration: hasStreak ? 2000.ms : 0.ms,
                      color: Colors.white.withOpacity(0.3),
                    ),
                const SizedBox(width: 6),
                // Streak count
                Text(
                  '$displayStreak',
                  style: TextStyle(
                    color: hasStreak ? Colors.white : Colors.grey.shade600,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showStreakDialog([int? streak]) {
    final displayStreak = streak ?? _currentStreak;
    final hasStreak = displayStreak > 0;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: hasStreak
                ? LinearGradient(
                    colors: [
                      Colors.orange.shade50,
                      Colors.white,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Large flame icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: hasStreak
                      ? LinearGradient(
                          colors: [
                            Colors.orange.shade400,
                            Colors.deepOrange.shade600,
                          ],
                        )
                      : LinearGradient(
                          colors: [
                            Colors.grey.shade300,
                            Colors.grey.shade400,
                          ],
                        ),
                  boxShadow: hasStreak
                      ? [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 48,
                ),
              )
                  .animate(
                    onPlay: (controller) => hasStreak ? controller.repeat(reverse: true) : null,
                  )
                  .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.05, 1.05),
                    duration: hasStreak ? 1500.ms : 0.ms,
                  ),
              const SizedBox(height: 24),
              
              // Streak count
              Text(
                '$displayStreak',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: hasStreak ? Colors.orange.shade700 : Colors.grey.shade600,
                  height: 1,
                ),
              ),
              const SizedBox(height: 8),
              
              // Title
              Text(
                hasStreak ? 'Day Streak!' : 'No Streak Yet',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: hasStreak ? Colors.orange.shade800 : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 12),
              
              // Description
              Text(
                hasStreak
                    ? displayStreak == 1
                        ? 'Great start! Study tomorrow to keep it going.'
                        : displayStreak < 7
                            ? 'You\'re on fire! Keep studying daily to maintain your streak.'
                            : displayStreak < 30
                                ? 'Amazing dedication! You\'re building a strong habit.'
                                : 'Legendary! You\'re a study master!'
                    : 'Start studying today to begin your streak!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              
              // Milestones
              if (hasStreak) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.orange.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Next Milestone',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: Colors.orange.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getNextMilestone(displayStreak),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasStreak ? Colors.orange.shade600 : Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Got it!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getNextMilestone(int streak) {
    if (streak < 7) {
      return '7 days (${7 - streak} to go)';
    } else if (streak < 14) {
      return '14 days (${14 - streak} to go)';
    } else if (streak < 30) {
      return '30 days (${30 - streak} to go)';
    } else if (streak < 60) {
      return '60 days (${60 - streak} to go)';
    } else if (streak < 100) {
      return '100 days (${100 - streak} to go)';
    } else if (streak < 365) {
      return '365 days (${365 - streak} to go)';
    } else {
      return 'You\'re a legend! 🏆';
    }
  }
}
