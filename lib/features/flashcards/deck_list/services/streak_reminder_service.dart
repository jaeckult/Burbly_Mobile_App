import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/background_service.dart';

/// Service to manage streak reminder dialogs
class StreakReminderService {
  static const String _lastStreakDialogKey = 'last_streak_dialog_date';
  
  /// Check if we should show the streak reminder dialog
  /// Returns true if it's a new day and user has an active streak
  static Future<bool> shouldShowStreakReminder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final backgroundService = BackgroundService();
      
      // Get current streak
      final currentStreak = await backgroundService.getCurrentStreak();
      if (currentStreak == 0) return false;
      
      // Get last time we showed the dialog (date only)
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month}-${today.day}';
      final lastDialogDate = prefs.getString(_lastStreakDialogKey);
      
      // Show dialog if we haven't shown it today
      if (lastDialogDate != todayString) {
        // Mark as shown for today
        await prefs.setString(_lastStreakDialogKey, todayString);
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error checking streak reminder: $e');
      return false;
    }
  }
  
  /// Show the streak reminder dialog
  static Future<void> showStreakReminderDialog(
    BuildContext context,
    int currentStreak,
  ) async {
    if (!context.mounted) return;
    
    final backgroundService = BackgroundService();
    final lastStudyDate = await backgroundService.getLastStudyDate();
    final today = DateTime.now();
    
    // Check if user studied today
    final studiedToday = lastStudyDate != null &&
        lastStudyDate.year == today.year &&
        lastStudyDate.month == today.month &&
        lastStudyDate.day == today.day;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
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
              // Animated flame icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade400,
                      Colors.deepOrange.shade600,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              
              // Welcome message
              Text(
                studiedToday ? 'Great Job! 🎉' : 'Welcome Back! 👋',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.orange.shade800,
                ),
              ),
              const SizedBox(height: 12),
              
              // Streak info
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                      text: studiedToday
                          ? 'You\'ve already studied today and maintained your '
                          : 'You have a ',
                    ),
                    TextSpan(
                      text: '$currentStreak day',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    TextSpan(
                      text: studiedToday
                          ? ' streak! Keep it up! 🔥'
                          : ' streak going! 🔥\n\nReview your decks today to keep it alive!',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Motivational message based on streak length
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
                  children: [
                    Icon(
                      _getStreakIcon(currentStreak),
                      color: Colors.orange.shade600,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getMotivationalMessage(currentStreak, studiedToday),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange.shade700,
                        side: BorderSide(color: Colors.orange.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Later',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (!studiedToday) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Could navigate to study screen here
                        },
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
                          'Study Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  static IconData _getStreakIcon(int streak) {
    if (streak >= 100) return Icons.emoji_events;
    if (streak >= 30) return Icons.star;
    if (streak >= 7) return Icons.trending_up;
    return Icons.favorite;
  }
  
  static String _getMotivationalMessage(int streak, bool studiedToday) {
    if (studiedToday) {
      if (streak >= 100) return 'You\'re a legend! Over 100 days of dedication!';
      if (streak >= 30) return 'Incredible! A full month of consistent studying!';
      if (streak >= 7) return 'One week strong! You\'re building an amazing habit!';
      return 'Great start! Keep the momentum going!';
    } else {
      if (streak >= 100) return 'Don\'t break your legendary streak! Study today!';
      if (streak >= 30) return 'You\'ve come so far! Don\'t break the chain now!';
      if (streak >= 7) return 'A week of hard work! Keep it going!';
      return 'Study today to keep your streak alive!';
    }
  }
}
