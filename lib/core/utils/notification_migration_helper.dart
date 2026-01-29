import '../services/native_notification_service.dart';
import '../services/notification_service.dart';
import 'package:flutter/material.dart';

/// Migration helper to gradually transition from old NotificationService to new NativeNotificationService
/// This allows existing code to continue working while we migrate to the new system.
/// 
/// USAGE:
/// - For flashcard-related notifications, use NotificationMigrationHelper methods
/// - These will use the new native system under the hood
/// - Old NotificationService is kept for non-critical features (history, settings UI)
class NotificationMigrationHelper {
  
  /// Schedule a flashcard review notification
  /// Maps to new native system
  static Future<bool> scheduleFlashcardReview({
    required String deckId,
    required String deckName,
    required int cardCount,
    required DateTime scheduledTime,
  }) async {
    // Generate unique ID from deck ID
    final reminderId = deckId.hashCode.abs();
    
    return await NativeNotificationService.scheduleFlashcardReview(
      reminderId: reminderId,
      scheduledTime: scheduledTime,
      deckName: deckName,
      cardCount: cardCount,
      deckId: deckId,
    );
  }
  
  /// Schedule a daily study reminder
  /// Maps to new native system
  static Future<bool> scheduleDailyStudyReminder({
    required DateTime scheduledTime,
    required String message,
  }) async {
    // Use a consistent ID for daily reminders
    const reminderId = 999; // Reserved for daily reminders
    
    return await NativeNotificationService.scheduleStudyReminder(
      reminderId: reminderId,
      scheduledTime: scheduledTime,
      title: 'Daily Study Reminder',
      message: message,
    );
  }
  
  /// Schedule an overdue cards reminder
  /// Maps to new native system
  static Future<bool> scheduleOverdueReminder({
    required int overdueCount,
    required DateTime scheduledTime,
  }) async {
    const reminderId = 998; // Reserved for overdue reminders
    
    return await NativeNotificationService.scheduleStudyReminder(
      reminderId: reminderId,
      scheduledTime: scheduledTime,
      title: 'Cards Overdue',
      message: 'You have $overdueCount overdue cards. Review them now!',
    );
  }
  
  /// Cancel a deck's review notification
  static Future<bool> cancelDeckNotification(String deckId) async {
    final reminderId = deckId.hashCode.abs();
    return await NativeNotificationService.cancelReminder(reminderId);
  }
  
  /// Cancel daily reminder
  static Future<bool> cancelDailyReminder() async {
    return await NativeNotificationService.cancelReminder(999);
  }
  
  /// Cancel overdue reminder
  static Future<bool> cancelOverdueReminder() async {
    return await NativeNotificationService.cancelReminder(998);
  }
  
  /// Get the old notification service for backwards compatibility
  /// Use this ONLY for:
  /// - Notification history/log viewing
  /// - Settings UI (display existing settings)
  /// - Non-critical features
  static NotificationService getLegacyService() {
    return NotificationService();
  }
  
  /// Check if we can schedule exact alarms
  static Future<bool> canScheduleExactAlarms() async {
    return await NativeNotificationService.canScheduleExactAlarms();
  }
}

/// Helper to map old notification settings to new system
class NotificationSettingsMigration {
  
  /// Migrate old daily reminder settings to new system
  static Future<void> migrateDailyRemindersToNativeSystem() async {
    try {
      final oldService = NotificationService();
      final settings = await oldService.getReminderSettings();
      
      if (settings != null) {
        final hour = settings['hour'] as int? ?? 9;
        final minute = settings['minute'] as int? ?? 0;
        
        // Schedule using new system for each enabled day
        final now = DateTime.now();
        final targetTime = DateTime(now.year, now.month, now.day, hour, minute);
        
        // If time has passed today, schedule for tomorrow
        final scheduledTime = targetTime.isBefore(now) 
            ? targetTime.add(const Duration(days: 1))
            : targetTime;
        
        await NotificationMigrationHelper.scheduleDailyStudyReminder(
          scheduledTime: scheduledTime,
          message: 'Time for your daily study session! 📚',
        );
        
        print('✅ Migrated daily reminder to new system: ${scheduledTime}');
      }
    } catch (e) {
      print('❌ Error migrating daily reminders: $e');
    }
  }
  
  /// Check if migration is needed (one-time check)
  static Future<bool> needsMigration() async {
    // Check if old settings exist but new system hasn't been set up
    try {
      final oldService = NotificationService();
      final settings = await oldService.getReminderSettings();
      return settings != null;
    } catch (e) {
      return false;
    }
  }
}
