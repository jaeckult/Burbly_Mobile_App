import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/notification_repository.dart';
import './reminder_service.dart';
import './data_service.dart';
import '../utils/logger.dart';
import '../models/notification.dart';
import '../models/flashcard.dart';
import '../models/deck.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final NotificationRepository _repository = NotificationRepository();
  late final ReminderService _reminderService;
  
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  tz.Location? _detectedTimezone;

  ReminderService get reminder => _reminderService;
  NotificationRepository get repository => _repository;

  // Channel IDs
  static const String dailyReminderChannelId = 'daily_reminder_channel';
  static const String overdueCardsChannelId = 'overdue_cards_channel';
  static const String studyStreakChannelId = 'study_streak_channel';
  static const String petNotificationChannelId = 'pet_notification_channel';
  static const String immediateChannelId = 'immediate_channel';

  Future<void> initialize() async {
    tz.initializeTimeZones();
    await _detectAndSetTimezone();
    
    _reminderService = ReminderService(
      notifications: _notifications,
      repository: _repository,
      detectedTimezone: () => _detectedTimezone,
    );

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _createNotificationChannels();
    await _requestPermissions();
  }

  Future<void> _detectAndSetTimezone() async {
    try {
      final now = DateTime.now();
      final utcOffset = now.timeZoneOffset;
      final timezoneNames = tz.timeZoneDatabase.locations.keys.toList();
      String? bestMatch;
      
      for (final name in timezoneNames) {
        try {
          final loc = tz.getLocation(name);
          if (tz.TZDateTime.now(loc).timeZoneOffset == utcOffset) {
            bestMatch = name;
            break;
          }
        } catch (_) {}
      }
      
      _detectedTimezone = tz.getLocation(bestMatch ?? 'UTC');
      AppLogger.notification('Timezone set to: ${_detectedTimezone?.name}');
    } catch (e) {
      AppLogger.error('Timezone detection failed', error: e);
    }
  }

  Future<void> _createNotificationChannels() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      final channels = [
        const AndroidNotificationChannel('daily_reminder_channel', 'Daily Study Reminders', importance: Importance.high),
        const AndroidNotificationChannel('overdue_cards_channel', 'Overdue Cards', importance: Importance.high),
        const AndroidNotificationChannel('study_streak_channel', 'Study Streaks'),
        const AndroidNotificationChannel('pet_notification_channel', 'Pet Notifications'),
        const AndroidNotificationChannel('immediate_channel', 'Immediate Notifications', importance: Importance.high),
        const AndroidNotificationChannel('card_review_channel', 'Card Review'),
      ];

      for (final channel in channels) {
        await androidPlugin.createNotificationChannel(channel);
      }
    }
  }

  Future<void> _requestPermissions() async {
    await _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    await _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(alert: true, badge: true, sound: true);
  }

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload ?? '';
    AppLogger.notification('Notification tapped: $payload');
    
    final nav = navigatorKey.currentState;
    if (nav == null) return;

    if (payload.startsWith('scheduled_review_')) {
      final deckId = payload.replaceFirst('scheduled_review_', '');
      _navigateToDeck(nav, deckId);
    } else if (payload == 'streak_reminder') {
      nav.pushNamed('/stats');
    } else if (['study_reminder', 'review_now', 'overdue_card'].contains(payload)) {
      nav.pushNamed('/study-mixed');
    }
  }

  Future<void> _navigateToDeck(NavigatorState nav, String deckId) async {
    final deck = await DataService().getDeck(deckId);
    if (deck != null) {
      nav.pushNamed('/deck-detail', arguments: {'deck': deck});
    } else {
      nav.pushNamed('/study-mixed');
    }
  }

  // --- IMMEDIATE NOTIFICATIONS ---

  Future<void> showPetNotification(String message) async {
    const androidDetails = AndroidNotificationDetails(
      petNotificationChannelId,
      'Pet Notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );
    const details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());
    await _notifications.show(DateTime.now().millisecondsSinceEpoch ~/ 1000, 'Your Pet Misses You! 🐾', message, details);
    await _repository.save(title: 'Your Pet Misses You! 🐾', message: message, type: NotificationType.general, data: {'source': 'pet'});
  }

  Future<void> showStudyReminderNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      overdueCardsChannelId,
      'Overdue Cards',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());
    await _notifications.show(DateTime.now().millisecondsSinceEpoch ~/ 1000, title, body, details, payload: 'study_reminder');
    await _repository.save(title: title, message: body, type: NotificationType.studyReminder);
  }

  Future<void> showReviewNowNotification(String deckName, String question, {String? deckId}) async {
    const androidDetails = AndroidNotificationDetails(
      'immediate_channel',
      'Review Now',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    final details = NotificationDetails(android: androidDetails, iOS: const DarwinNotificationDetails());
    final title = 'Review Now: $deckName';
    final message = 'Time to review: $question';
    await _notifications.show(DateTime.now().millisecondsSinceEpoch ~/ 1000, title, message, details, payload: deckId != null ? 'scheduled_review_$deckId' : 'review_now');
    await _repository.save(title: title, message: message, type: NotificationType.studyReminder, data: {'deckId': deckId});
  }

  // --- REMINDER SCHEDULING (Delegated to ReminderService) ---

  Future<void> scheduleDailyReminder({required TimeOfDay time, required List<int> daysOfWeek}) =>
      _reminderService.scheduleDailyReminder(time: time, daysOfWeek: daysOfWeek);

  Future<void> scheduleOverdueCardsReminder([int count = 0]) => _reminderService.scheduleOverdueCardsReminder(count);

  Future<void> scheduleStudyStreakReminder(int streakDays) => _reminderService.scheduleStudyStreakReminder(streakDays);

  Future<void> schedulePetNotification(String message, {int delayHours = 2}) =>
      _reminderService.schedulePetNotification(message, delayHours: delayHours);

  Future<void> scheduleCardReviewNotification(Flashcard flashcard, Deck deck, DateTime nextReview) =>
      _reminderService.scheduleCardReviewNotification(flashcard, deck, nextReview);

  // --- REPOSITORY DELEGATES ---

  Future<void> saveNotification({required String title, required String message, required NotificationType type, Map<String, dynamic>? data}) =>
      _repository.save(title: title, message: message, type: type, data: data);

  Future<List<AppNotification>> getNotifications() => _repository.getAll();
  
  Future<void> markNotificationAsRead(String id) => _repository.markAsRead(id);
  Future<void> markAllNotificationsAsRead() => _repository.markAllAsRead();
  Future<void> deleteNotification(String id) => _repository.delete(id);

  // --- SETTINGS & PERMISSIONS ---

  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('overdue_reminders_enabled') ?? true;
  }

  Future<Map<String, dynamic>?> getReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('reminder_hour')) return null;
    
    return {
      'hour': prefs.getInt('reminder_hour') ?? 9,
      'minute': prefs.getInt('reminder_minute') ?? 0,
      'days': prefs.getStringList('reminder_days') ?? ['1', '2', '3', '4', '5', '6', '7'],
    };
  }

  Future<bool> requestNotificationPermissions() async {
    final android = await _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    final ios = await _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(alert: true, badge: true, sound: true);
    return (android ?? false) || (ios ?? false);
  }

  // --- COMPATIBILITY HELPERS ---

  Future<List<Flashcard>> getOverdueCards() async => [];
  Future<List<Flashcard>> getCardsDueToday() async => [];
  Future<List<Flashcard>> getCardsDueSoon() async => [];

  Future<void> updateDeckReviewNotification(Deck deck) async {}
  Future<void> updateFlashcardReviewNotification(Flashcard card, Deck deck) async {}
  Future<void> cancelDeckReviewNotification(String deckId) async {}

  static const int dailyReminderId = 1000;
  
  Future<void> cancelAllNotifications() => _notifications.cancelAll();
  Future<void> cancelNotification(int id) => _notifications.cancel(id);
  
  Future<void> checkAndRescheduleNotifications() async {}
}
