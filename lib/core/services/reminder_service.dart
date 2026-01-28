import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/deck.dart';
import '../models/flashcard.dart';
import '../models/notification.dart';
import '../repositories/notification_repository.dart';
import '../utils/logger.dart';

/// Service for scheduling specific study and feature reminders.
class ReminderService {
  final FlutterLocalNotificationsPlugin _notifications;
  final NotificationRepository _repository;
  final tz.Location? Function() _detectedTimezone;

  // IDs and Channels from NotificationService
  static const int dailyReminderId = 1000;
  static const int overdueCardsId = 2000;
  static const int studyStreakId = 3000;

  static const String dailyReminderChannelId = 'daily_reminder_channel';
  static const String overdueCardsChannelId = 'overdue_cards_channel';
  static const String studyStreakChannelId = 'study_streak_channel';
  static const String petNotificationChannelId = 'pet_notification_channel';

  ReminderService({
    required FlutterLocalNotificationsPlugin notifications,
    required NotificationRepository repository,
    required tz.Location? Function() detectedTimezone,
  })  : _notifications = notifications,
        _repository = repository,
        _detectedTimezone = detectedTimezone;

  /// Schedule a daily reminder for specified days of week
  Future<void> scheduleDailyReminder({
    required TimeOfDay time,
    required List<int> daysOfWeek,
  }) async {
    try {
      await _cancelDailyReminders();

      if (daysOfWeek.isEmpty) return;

      final details = _getDetails(dailyReminderChannelId, 'Daily Study Reminders');

      for (final day in daysOfWeek) {
        final scheduledTime = _nextInstanceOfDay(time, day);
        final now = tz.TZDateTime.now(tz.local);
        final isToday = day == now.weekday;
        
        await _notifications.zonedSchedule(
          dailyReminderId + day,
          'Time to Study! 📚',
          'You have flashcards waiting for review. Keep your streak going!',
          scheduledTime,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: isToday ? null : DateTimeComponents.dayOfWeekAndTime,
          payload: 'study_reminder',
        );
      }

      await _saveReminderSettings(time, daysOfWeek);
      AppLogger.notification('Scheduled daily reminders for: $daysOfWeek', tag: 'Reminder');
    } catch (e) {
      AppLogger.error('Error scheduling daily reminders', error: e, tag: 'Reminder');
    }
  }

  /// Schedule overdue cards reminder (typically 2 hours from now)
  Future<void> scheduleOverdueCardsReminder(int count) async {
    if (count == 0) return;
    try {
      await _notifications.cancel(overdueCardsId);

      final details = _getDetails(overdueCardsChannelId, 'Overdue Cards', importance: Importance.high);
      final scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(hours: 2));
      
      await _notifications.zonedSchedule(
        overdueCardsId,
        'Cards Need Review! ⏰',
        'You have $count overdue cards waiting for review.',
        scheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'overdue_card',
      );
    } catch (e) {
      AppLogger.error('Error scheduling overdue reminder', error: e, tag: 'Reminder');
    }
  }

  /// Schedule study streak celebration/reminder
  Future<void> scheduleStudyStreakReminder(int streakDays) async {
    try {
      await _notifications.cancel(studyStreakId);

      final details = _getDetails(studyStreakChannelId, 'Study Streaks', importance: Importance.defaultImportance);
      final scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(hours: 1));
      
      final title = 'Amazing Streak! 🔥';
      final message = 'You\'ve studied for $streakDays days in a row! Keep it up!';
      
      await _notifications.zonedSchedule(
        studyStreakId,
        title,
        message,
        scheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'streak_reminder',
      );

      await _repository.save(
        title: title,
        message: message,
        type: NotificationType.streakAchievement,
        data: {'streakDays': streakDays},
      );
    } catch (e) {
      AppLogger.error('Error scheduling streak reminder', error: e, tag: 'Reminder');
    }
  }

  /// Schedule a notification from the study pet
  Future<void> schedulePetNotification(String message, {int delayHours = 2}) async {
    try {
      final details = _getDetails(petNotificationChannelId, 'Pet Notifications', importance: Importance.defaultImportance);
      final scheduledTime = tz.TZDateTime.now(tz.local).add(Duration(hours: delayHours));
      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final title = 'Your Pet Misses You! 🐾';
      
      await _notifications.zonedSchedule(
        notificationId,
        title,
        message,
        scheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );

      await _repository.save(
        title: title,
        message: message,
        type: NotificationType.general,
        data: {'source': 'pet', 'scheduledTime': scheduledTime.toIso8601String()},
      );
    } catch (e) {
      AppLogger.error('Error scheduling pet notification', error: e, tag: 'Reminder');
    }
  }

  /// Schedule specific deck/card review (spaced repetition)
  Future<void> scheduleCardReviewNotification(Flashcard flashcard, Deck deck, DateTime nextReview) async {
    try {
      final details = _getDetails('card_review_channel', 'Card Review', importance: Importance.defaultImportance);
      final notificationId = 6000 + (flashcard.id.hashCode % 1000);
      final timezone = _detectedTimezone() ?? tz.local;
      final scheduledTime = tz.TZDateTime.from(nextReview, timezone);

      if (scheduledTime.isBefore(tz.TZDateTime.now(timezone))) return;

      await _notifications.zonedSchedule(
        notificationId,
        'Review Due: ${deck.name}',
        'Time to review: ${flashcard.question.substring(0, flashcard.question.length > 50 ? 50 : flashcard.question.length)}',
        scheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'card_review_${flashcard.id}',
      );
    } catch (e) {
      AppLogger.error('Error scheduling card review', error: e, tag: 'Reminder');
    }
  }

  // --- HELPERS ---

  NotificationDetails _getDetails(String channelId, String channelName, {Importance importance = Importance.high}) {
    final android = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: importance,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const ios = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true);
    return NotificationDetails(android: android, iOS: ios);
  }

  Future<void> _cancelDailyReminders() async {
    for (int day = 1; day <= 7; day++) {
      await _notifications.cancel(dailyReminderId + day);
    }
  }

  tz.TZDateTime _nextInstanceOfDay(TimeOfDay time, int dayOfWeek) {
    final timezone = _detectedTimezone() ?? tz.local;
    tz.TZDateTime now = tz.TZDateTime.now(timezone);
    
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      timezone,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    while (scheduledDate.weekday != dayOfWeek || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> _saveReminderSettings(TimeOfDay time, List<int> daysOfWeek) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_hour', time.hour);
    await prefs.setInt('reminder_minute', time.minute);
    await prefs.setStringList('reminder_days', daysOfWeek.map((e) => e.toString()).toList());
  }
}
