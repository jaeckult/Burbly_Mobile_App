import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Celebration dialog shown when user completes first study of the day
class StreakCelebrationDialog {
  static Future<void> show(
    BuildContext context, {
    required int newStreak,
    required bool streakIncreased,
  }) async {
    if (!context.mounted) return;

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                Colors.orange.shade50,
                Colors.white,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Celebration animation
              SizedBox(
                width: 120,
                height: 120,
                child: Lottie.network(
                  'https://lottie.host/647eb68e-e5a0-4145-b23a-f9a5b7a8c39e/6FyZKJCMNc.json',
                  repeat: false,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.celebration,
                      size: 80,
                      color: Colors.orange.shade600,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Flame icon with streak count
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade400,
                      Colors.deepOrange.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$newStreak',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                streakIncreased ? 'Streak Updated! 🎉' : 'First Study Today! 🎯',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.orange.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                streakIncreased
                    ? 'Amazing! You\'ve studied for $newStreak days in a row! Keep up the great work!'
                    : newStreak == 1
                        ? 'Great start! Study again tomorrow to build your streak!'
                        : 'You\'ve maintained your $newStreak day streak! Keep it going!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Motivational badge
              if (newStreak >= 7)
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getMilestoneIcon(newStreak),
                        color: Colors.orange.shade600,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _getMilestoneText(newStreak),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              if (newStreak >= 7) const SizedBox(height: 20),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Awesome!',
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

  static IconData _getMilestoneIcon(int streak) {
    if (streak >= 100) return Icons.emoji_events;
    if (streak >= 30) return Icons.star;
    if (streak >= 7) return Icons.trending_up;
    return Icons.favorite;
  }

  static String _getMilestoneText(int streak) {
    if (streak >= 100) return 'Century Club! 🏆';
    if (streak >= 30) return 'Month Master! ⭐';
    if (streak >= 7) return 'Week Warrior! 💪';
    return '';
  }
}
