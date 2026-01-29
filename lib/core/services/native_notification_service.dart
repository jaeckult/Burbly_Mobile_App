import 'package:flutter/services.dart';
import 'dart:io';

/// Robust notification service using native Android AlarmManager.
/// This provides reliable, battery-efficient notifications that work offline.
class NativeNotificationService {
  static const MethodChannel _channel = MethodChannel('com.burbly.app/notifications');
  
  // Notification types (must match AlarmReceiver constants)
  static const String typeStudyReminder = 'study_reminder';
  static const String typeFlashcardReview = 'flashcard_review';
  static const String typeDailyGoal = 'daily_goal';
  
  /// Initialize the service and check if rescheduling is needed (call on app start)
  static Future<void> initialize() async {
    if (!Platform.isAndroid) return;
    
    try {
      // Check if alarms need rescheduling after boot/update
      final needsReschedule = await checkNeedsReschedule();
      if (needsReschedule) {
        print('⚠️ Device was rebooted or app updated - rescheduling notifications');
        // Trigger reschedule callback
        await _onNeedsReschedule();
      }
      
      // Listen for reschedule requests from native side
      _channel.setMethodCallHandler(_handleMethodCall);
      
      print('✅ NativeNotificationService initialized');
    } catch (e) {
      print('❌ Error initializing NativeNotificationService: $e');
    }
  }
  
  /// Schedule a study reminder notification
  static Future<bool> scheduleStudyReminder({
    required int reminderId,
    required DateTime scheduledTime,
    required String title,
    required String message,
  }) async {
    if (!Platform.isAndroid) return false;
    
    try {
      final result = await _channel.invokeMethod('scheduleReminder', {
        'reminderId': reminderId,
        'notificationType': typeStudyReminder,
        'title': title,
        'message': message,
        'scheduledTime': scheduledTime.millisecondsSinceEpoch,
      });
      
      print('📅 Scheduled study reminder #$reminderId for $scheduledTime');
      return result == true;
    } catch (e) {
      print('❌ Error scheduling study reminder: $e');
      return false;
    }
  }
  
  /// Schedule a flashcard review notification
  static Future<bool> scheduleFlashcardReview({
    required int reminderId,
    required DateTime scheduledTime,
    required String deckName,
    required int cardCount,
    required String deckId,
  }) async {
    if (!Platform.isAndroid) return false;
    
    try {
      final result = await _channel.invokeMethod('scheduleReminder', {
        'reminderId': reminderId,
        'notificationType': typeFlashcardReview,
        'title': 'Time to Review Flashcards!',
        'message': '$cardCount cards in "$deckName" are due for review',
        'scheduledTime': scheduledTime.millisecondsSinceEpoch,
        'deckName': deckName,
        'cardCount': cardCount,
        'deckId': deckId,
      });
      
      print('📅 Scheduled flashcard review #$reminderId for $deckName at $scheduledTime');
      return result == true;
    } catch (e) {
      print('❌ Error scheduling flashcard review: $e');
      return false;
    }
  }
  
  /// Schedule a daily goal reminder
  static Future<bool> scheduleDailyGoal({
    required int reminderId,
    required DateTime scheduledTime,
    required String goalProgress,
  }) async {
    if (!Platform.isAndroid) return false;
    
    try {
      final result = await _channel.invokeMethod('scheduleReminder', {
        'reminderId': reminderId,
        'notificationType': typeDailyGoal,
        'title': 'Daily Study Goal',
        'message': goalProgress,
        'scheduledTime': scheduledTime.millisecondsSinceEpoch,
      });
      
      print('📅 Scheduled daily goal #$reminderId for $scheduledTime');
      return result == true;
    } catch (e) {
      print('❌ Error scheduling daily goal: $e');
      return false;
    }
  }
  
  /// Cancel a specific reminder
  static Future<bool> cancelReminder(int reminderId) async {
    if (!Platform.isAndroid) return false;
    
    try {
      final result = await _channel.invokeMethod('cancelReminder', {
        'reminderId': reminderId,
      });
      
      print('🗑️ Cancelled reminder #$reminderId');
      return result == true;
    } catch (e) {
      print('❌ Error cancelling reminder: $e');
      return false;
    }
  }
  
  /// Reschedule all reminders (called after boot or when needed)
  static Future<int> rescheduleAll(List<ReminderData> reminders) async {
    if (!Platform.isAndroid) return 0;
    
    try {
      final reminderMaps = reminders.map((r) => r.toMap()).toList();
      final successCount = await _channel.invokeMethod('rescheduleAll', {
        'reminders': reminderMaps,
      });
      
      print('🔄 Rescheduled $successCount/${reminders.length} reminders');
      return successCount as int;
    } catch (e) {
      print('❌ Error rescheduling all reminders: $e');
      return 0;
    }
  }
  
  /// Check if device can schedule exact alarms
  static Future<bool> canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return false;
    
    try {
      final result = await _channel.invokeMethod('canScheduleExactAlarms');
      return result == true;
    } catch (e) {
      print('❌ Error checking exact alarm capability: $e');
      return false;
    }
  }
  
  /// Check if alarms need rescheduling
  static Future<bool> checkNeedsReschedule() async {
    if (!Platform.isAndroid) return false;
    
    try {
      final result = await _channel.invokeMethod('checkNeedsReschedule');
      return result == true;
    } catch (e) {
      print('❌ Error checking reschedule status: $e');
      return false;
    }
  }
  
  /// Handle method calls from native side
  static Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onNeedsReschedule':
        await _onNeedsReschedule();
        break;
      case 'openDeck':
        // Deep link from notification tap
        final deckId = call.arguments['deckId'] as String?;
        if (deckId != null) {
          await _handleOpenDeck(deckId);
        }
        break;
      default:
        print('Unknown method from native: ${call.method}');
    }
  }
  
  /// Handle deep link to open specific deck
  static Future<void> _handleOpenDeck(String deckId) async {
    print('🔗 Opening deck from notification: $deckId');
    
    // The navigation will be handled by the app itself
    // We just log this for now - actual navigation happens in Flutter layer
    // through a global navigator key or app-level routing
    
    // TODO: Implement navigation to deck detail screen
    // This would require access to navigator context or a global navigation handler
    print('⚠️ Deep link handling needs app-level navigation integration');
  }
  
  /// Called when alarms need to be rescheduled
  static Future<void> _onNeedsReschedule() async {
    // This is where you'd load all saved reminders from your database
    // and reschedule them. Example:
    
    print('🔄 Rescheduling all reminders...');
    
    // TODO: Load reminders from your database (Hive/Isar/SQLite)
    // final reminders = await yourDatabase.getAllReminders();
    // await rescheduleAll(reminders);
    
    // For now, just log the event
    print('⚠️ App needs to implement reminder rescheduling logic');
  }
}

/// Data class for reminder information
class ReminderData {
  final int reminderId;
  final String notificationType;
  final String title;
  final String message;
  final DateTime scheduledTime;
  final String? deckName;
  final int? cardCount;
  
  const ReminderData({
    required this.reminderId,
    required this.notificationType,
    required this.title,
    required this.message,
    required this.scheduledTime,
    this.deckName,
    this.cardCount,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'reminderId': reminderId,
      'notificationType': notificationType,
      'title': title,
      'message': message,
      'scheduledTime': scheduledTime.millisecondsSinceEpoch,
      'deckName': deckName,
      'cardCount': cardCount,
    };
  }
  
  factory ReminderData.fromMap(Map<String, dynamic> map) {
    return ReminderData(
      reminderId: map['reminderId'] as int,
      notificationType: map['notificationType'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      scheduledTime: DateTime.fromMillisecondsSinceEpoch(map['scheduledTime'] as int),
      deckName: map['deckName'] as String?,
      cardCount: map['cardCount'] as int?,
    );
  }
}
