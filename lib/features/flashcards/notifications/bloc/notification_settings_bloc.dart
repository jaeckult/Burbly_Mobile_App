import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/background_service.dart';
import 'notification_settings_event.dart';
import 'notification_settings_state.dart';

class NotificationSettingsBloc extends Bloc<NotificationSettingsEvent, NotificationSettingsState> {
  final NotificationService _notificationService;
  final BackgroundService _backgroundService;

  NotificationSettingsBloc({
    required NotificationService notificationService,
    required BackgroundService backgroundService,
  })  : _notificationService = notificationService,
        _backgroundService = backgroundService,
        super(const NotificationSettingsState()) {
    on<LoadNotificationSettings>(_onLoad);
    on<ToggleDailyReminders>(_onToggleDailyReminders);
    on<SetDailyReminderTime>(_onSetDailyReminderTime);
    on<ToggleReminderDay>(_onToggleReminderDay);
    on<ToggleOverdueReminders>(_onToggleOverdueReminders);
    on<ToggleStreakReminders>(_onToggleStreakReminders);
    on<RequestNotificationPermissions>(_onRequestPermissions);
    on<RefreshNotificationStats>(_onRefreshStats);
  }

  Future<void> _onLoad(LoadNotificationSettings event, Emitter<NotificationSettingsState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final enabled = await _notificationService.areNotificationsEnabled();

      // Load saved reminder settings
      TimeOfDay selectedTime = state.selectedTime;
      List<int> selectedDays = state.selectedDays;
      bool dailyEnabled = state.dailyRemindersEnabled;
      final settings = await _notificationService.getReminderSettings();
      if (settings != null) {
        selectedTime = TimeOfDay(
          hour: settings['hour'] as int,
          minute: settings['minute'] as int,
        );
        selectedDays = (settings['days'] as List<String>).map(int.parse).toList();
        dailyEnabled = true;
      }

      // Load other toggles from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final overdueEnabled = prefs.getBool('overdue_reminders_enabled') ?? true;
      final streakEnabled = prefs.getBool('streak_reminders_enabled') ?? true;

      // Stats
      final stats = await _backgroundService.getNotificationStats();

      emit(state.copyWith(
        isLoading: false,
        notificationsEnabled: enabled,
        dailyRemindersEnabled: dailyEnabled,
        overdueRemindersEnabled: overdueEnabled,
        streakRemindersEnabled: streakEnabled,
        selectedTime: selectedTime,
        selectedDays: selectedDays,
        stats: stats,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _persistDailySchedule(Emitter<NotificationSettingsState> emit, {TimeOfDay? time, List<int>? days}) async {
    final t = time ?? state.selectedTime;
    final d = days ?? state.selectedDays;

    if (state.dailyRemindersEnabled) {
      await _notificationService.scheduleDailyReminder(time: t, daysOfWeek: d);
    } else {
      // Cancel any existing daily reminders
      for (int day = 1; day <= 7; day++) {
        await _notificationService.cancelNotification(NotificationService.dailyReminderId + day);
      }
    }
  }

  Future<void> _onToggleDailyReminders(ToggleDailyReminders event, Emitter<NotificationSettingsState> emit) async {
    emit(state.copyWith(dailyRemindersEnabled: event.enabled, clearError: true));
    try {
      await _persistDailySchedule(emit);
      final stats = await _backgroundService.getNotificationStats();
      emit(state.copyWith(stats: stats));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onSetDailyReminderTime(SetDailyReminderTime event, Emitter<NotificationSettingsState> emit) async {
    emit(state.copyWith(selectedTime: event.time, clearError: true));
    try {
      await _persistDailySchedule(emit, time: event.time);
      final stats = await _backgroundService.getNotificationStats();
      emit(state.copyWith(stats: stats));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onToggleReminderDay(ToggleReminderDay event, Emitter<NotificationSettingsState> emit) async {
    final newDays = List<int>.from(state.selectedDays);
    if (newDays.contains(event.dayOfWeek)) {
      newDays.remove(event.dayOfWeek);
    } else {
      newDays.add(event.dayOfWeek);
      newDays.sort();
    }
    emit(state.copyWith(selectedDays: newDays, clearError: true));
    try {
      await _persistDailySchedule(emit, days: newDays);
      final stats = await _backgroundService.getNotificationStats();
      emit(state.copyWith(stats: stats));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onToggleOverdueReminders(ToggleOverdueReminders event, Emitter<NotificationSettingsState> emit) async {
    emit(state.copyWith(overdueRemindersEnabled: event.enabled, clearError: true));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('overdue_reminders_enabled', event.enabled);
      final stats = await _backgroundService.getNotificationStats();
      emit(state.copyWith(stats: stats));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onToggleStreakReminders(ToggleStreakReminders event, Emitter<NotificationSettingsState> emit) async {
    emit(state.copyWith(streakRemindersEnabled: event.enabled, clearError: true));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('streak_reminders_enabled', event.enabled);
      final stats = await _backgroundService.getNotificationStats();
      emit(state.copyWith(stats: stats));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onRequestPermissions(RequestNotificationPermissions event, Emitter<NotificationSettingsState> emit) async {
    try {
      final granted = await _notificationService.requestNotificationPermissions();
      emit(state.copyWith(notificationsEnabled: granted));
      final stats = await _backgroundService.getNotificationStats();
      emit(state.copyWith(stats: stats));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onRefreshStats(RefreshNotificationStats event, Emitter<NotificationSettingsState> emit) async {
    try {
      final stats = await _backgroundService.getNotificationStats();
      emit(state.copyWith(stats: stats));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
