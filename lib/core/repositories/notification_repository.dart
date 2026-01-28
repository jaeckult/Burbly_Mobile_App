import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification.dart';
import '../utils/logger.dart';

/// Repository for managing application notifications stored in SharedPreferences.
class NotificationRepository {
  static const String _notificationsKey = 'app_notifications';
  static const int _maxNotifications = 50;

  /// Save a new notification
  Future<void> save({
    required String title,
    required String message,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingNotifications = await getAll();
      
      // Create new notification
      final newNotification = AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        message: message,
        type: type,
        timestamp: DateTime.now(),
        data: data,
      );
      
      // Add to beginning of list (newest first)
      existingNotifications.insert(0, newNotification);
      
      // Keep only the limit
      if (existingNotifications.length > _maxNotifications) {
        existingNotifications.removeRange(_maxNotifications, existingNotifications.length);
      }
      
      // Save back
      final updatedJson = existingNotifications
          .map((n) => jsonEncode(n.toJson()))
          .toList();
      await prefs.setStringList(_notificationsKey, updatedJson);
      
      AppLogger.notification('Saved notification: $title', tag: 'Repo');
    } catch (e) {
      AppLogger.error('Error saving notification', error: e, tag: 'Repo');
    }
  }

  /// Get all notifications
  Future<List<AppNotification>> getAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList(_notificationsKey) ?? [];
      
      final notifications = notificationsJson
          .map((jsonString) {
            try {
              final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
              return AppNotification.fromJson(jsonMap);
            } catch (e) {
              return null;
            }
          })
          .where((n) => n != null)
          .cast<AppNotification>()
          .toList();
      
      // Sort by timestamp (newest first)
      notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      return notifications;
    } catch (e) {
      AppLogger.error('Error getting notifications', error: e, tag: 'Repo');
      return [];
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String id) async {
    try {
      final notifications = await getAll();
      bool modified = false;
      
      final updatedNotifications = notifications.map((n) {
        if (n.id == id && !n.isRead) {
          modified = true;
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();
      
      if (modified) {
        await _saveAll(updatedNotifications);
      }
    } catch (e) {
      AppLogger.error('Error marking notification as read', error: e, tag: 'Repo');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final notifications = await getAll();
      final updatedNotifications = notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      await _saveAll(updatedNotifications);
    } catch (e) {
      AppLogger.error('Error marking all notifications as read', error: e, tag: 'Repo');
    }
  }

  /// Delete a notification
  Future<void> delete(String id) async {
    try {
      final notifications = await getAll();
      final updatedNotifications = notifications
          .where((n) => n.id != id)
          .toList();
      await _saveAll(updatedNotifications);
    } catch (e) {
      AppLogger.error('Error deleting notification', error: e, tag: 'Repo');
    }
  }

  /// Internal helper to save list
  Future<void> _saveAll(List<AppNotification> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = notifications
        .map((n) => jsonEncode(n.toJson()))
        .toList();
    await prefs.setStringList(_notificationsKey, jsonList);
  }
}
