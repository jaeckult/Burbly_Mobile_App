import 'package:flutter/material.dart';
import '../../../core/services/native_notification_service.dart';

/// Example implementation showing how to use the NativeNotificationService
/// in your Flutter app for flashcard study reminders.
class NotificationExample extends StatefulWidget {
  const NotificationExample({super.key});

  @override
  State<NotificationExample> createState() => _NotificationExampleState();
}

class _NotificationExampleState extends State<NotificationExample> {
  bool _canScheduleExact = false;
  
  @override
  void initState() {
    super.initState();
    _checkExactAlarmCapability();
  }
  
  Future<void> _checkExactAlarmCapability() async {
    final canSchedule = await NativeNotificationService.canScheduleExactAlarms();
    setState(() => _canScheduleExact = canSchedule);
  }
  
  /// Example 1: Schedule a study reminder for tomorrow at 9 AM
  Future<void> _scheduleDailyStudyReminder() async {
    final tomorrow9AM = DateTime.now().add(const Duration(days: 1)).copyWith(
      hour: 9,
      minute: 0,
      second: 0,
      millisecond: 0,
    );
    
    final success = await NativeNotificationService.scheduleStudyReminder(
      reminderId: 1001,
      scheduledTime: tomorrow9AM,
      title: 'Daily Study Session',
      message: 'Time for your morning flashcard review! 📚',
    );
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Study reminder scheduled for tomorrow at 9 AM')),
      );
    }
  }
  
  /// Example 2: Schedule a flashcard review reminder
  Future<void> _scheduleFlashcardReview() async {
    final in2Hours = DateTime.now().add(const Duration(hours: 2));
    
    final success = await NativeNotificationService.scheduleFlashcardReview(
      reminderId: 2001,
      scheduledTime: in2Hours,
      deckName: 'Spanish Vocabulary',
      cardCount: 25,
      deckId: 'spanish_vocabulary_deck',
    );
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flashcard review reminder set for 2 hours from now')),
      );
    }
  }
  
  /// Example 3: Schedule daily goal reminder
  Future<void> _scheduleDailyGoal() async {
    final tonight8PM = DateTime.now().copyWith(
      hour: 20,
      minute: 0,
      second: 0,
      millisecond: 0,
    );
    
    final success = await NativeNotificationService.scheduleDailyGoal(
      reminderId: 3001,
      scheduledTime: tonight8PM,
      goalProgress: "You've studied 15 cards today. Keep it up! 🎯",
    );
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daily goal reminder set for 8 PM')),
      );
    }
  }
  
  /// Example 4: Schedule multiple reminders at once
  Future<void> _scheduleMultipleReminders() async {
    final now = DateTime.now();
    
    // Morning reminder
    await NativeNotificationService.scheduleStudyReminder(
      reminderId: 1001,
      scheduledTime: now.add(const Duration(hours: 8)),
      title: 'Morning Study',
      message: 'Start your day with some flashcards!',
    );
    
    // Afternoon reminder
    await NativeNotificationService.scheduleStudyReminder(
      reminderId: 1002,
      scheduledTime: now.add(const Duration(hours: 14)),
      title: 'Afternoon Review',
      message: 'Quick 10-minute review session!',
    );
    
    // Evening reminder
    await NativeNotificationService.scheduleStudyReminder(
      reminderId: 1003,
      scheduledTime: now.add(const Duration(hours: 20)),
      title: 'Evening Practice',
      message: 'End your day by reviewing what you learned!',
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('3 study reminders scheduled!')),
    );
  }
  
  /// Example 5: Cancel a specific reminder
  Future<void> _cancelReminder(int reminderId) async {
    final success = await NativeNotificationService.cancelReminder(reminderId);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reminder #$reminderId cancelled')),
      );
    }
  }
  
  /// Example 6: Reschedule all reminders (useful after boot)
  Future<void> _rescheduleAllReminders() async {
    // In a real app, you'd load these from your database
    final reminders = [
      ReminderData(
        reminderId: 1001,
        notificationType: NativeNotificationService.typeStudyReminder,
        title: 'Morning Study',
        message: 'Time to study!',
        scheduledTime: DateTime.now().add(const Duration(hours: 8)),
      ),
      ReminderData(
        reminderId: 2001,
        notificationType: NativeNotificationService.typeFlashcardReview,
        title: 'Flashcard Review',
        message: '20 cards in "Math Formulas" are due',
        scheduledTime: DateTime.now().add(const Duration(hours: 12)),
        deckName: 'Math Formulas',
        cardCount: 20,
      ),
    ];
    
    final successCount = await NativeNotificationService.rescheduleAll(reminders);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rescheduled $successCount/${reminders.length} reminders')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Exact alarm status
          Card(
            color: _canScheduleExact ? Colors.green.shade50 : Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    _canScheduleExact ? Icons.check_circle : Icons.warning,
                    color: _canScheduleExact ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _canScheduleExact
                          ? 'Exact alarms enabled - notifications will be precise'
                          : 'Using inexact alarms - notifications may be delayed slightly',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Example buttons
          _buildExampleButton(
            'Schedule Daily Study Reminder',
            'Tomorrow at 9 AM',
            Icons.alarm,
            _scheduleDailyStudyReminder,
          ),
          
          _buildExampleButton(
            'Schedule Flashcard Review',
            'In 2 hours',
            Icons.style,
            _scheduleFlashcardReview,
          ),
          
          _buildExampleButton(
            'Schedule Daily Goal Reminder',
            'Tonight at 8 PM',
            Icons.flag,
            _scheduleDailyGoal,
          ),
          
          _buildExampleButton(
            'Schedule Multiple Reminders',
            'Morning, afternoon, and evening',
            Icons.repeat,
            _scheduleMultipleReminders,
          ),
          
          const Divider(height: 32),
          
          _buildExampleButton(
            'Cancel Reminder #1001',
            'Remove scheduled reminder',
            Icons.cancel,
            () => _cancelReminder(1001),
            color: Colors.red,
          ),
          
          _buildExampleButton(
            'Reschedule All Reminders',
            'Useful after device reboot',
            Icons.refresh,
            _rescheduleAllReminders,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
  
  Widget _buildExampleButton(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    Color? color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color ?? Theme.of(context).primaryColor),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
