import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class NotificationSettingsEvent extends Equatable {
  const NotificationSettingsEvent();
  @override
  List<Object?> get props => [];
}

class LoadNotificationSettings extends NotificationSettingsEvent {
  const LoadNotificationSettings();
}

class ToggleDailyReminders extends NotificationSettingsEvent {
  final bool enabled;
  const ToggleDailyReminders(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class SetDailyReminderTime extends NotificationSettingsEvent {
  final TimeOfDay time;
  const SetDailyReminderTime(this.time);
  @override
  List<Object?> get props => [time];
}

class ToggleReminderDay extends NotificationSettingsEvent {
  final int dayOfWeek; // 1..7 (Mon..Sun)
  const ToggleReminderDay(this.dayOfWeek);
  @override
  List<Object?> get props => [dayOfWeek];
}

class ToggleOverdueReminders extends NotificationSettingsEvent {
  final bool enabled;
  const ToggleOverdueReminders(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class ToggleStreakReminders extends NotificationSettingsEvent {
  final bool enabled;
  const ToggleStreakReminders(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class RequestNotificationPermissions extends NotificationSettingsEvent {
  const RequestNotificationPermissions();
}

class RefreshNotificationStats extends NotificationSettingsEvent {
  const RefreshNotificationStats();
}
