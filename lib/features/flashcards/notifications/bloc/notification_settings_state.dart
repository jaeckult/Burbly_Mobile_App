import 'package:equatable/equatable.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class NotificationSettingsState extends Equatable {
  final bool isLoading;
  final bool notificationsEnabled;
  final bool dailyRemindersEnabled;
  final bool overdueRemindersEnabled;
  final bool streakRemindersEnabled;
  final TimeOfDay selectedTime;
  final List<int> selectedDays; // 1..7
  final Map<String, dynamic> stats;
  final String? errorMessage;

  const NotificationSettingsState({
    this.isLoading = false,
    this.notificationsEnabled = false,
    this.dailyRemindersEnabled = false,
    this.overdueRemindersEnabled = false,
    this.streakRemindersEnabled = false,
    this.selectedTime = const TimeOfDay(hour: 9, minute: 0),
    this.selectedDays = const [1, 2, 3, 4, 5, 6, 7],
    this.stats = const {},
    this.errorMessage,
  });

  NotificationSettingsState copyWith({
    bool? isLoading,
    bool? notificationsEnabled,
    bool? dailyRemindersEnabled,
    bool? overdueRemindersEnabled,
    bool? streakRemindersEnabled,
    TimeOfDay? selectedTime,
    List<int>? selectedDays,
    Map<String, dynamic>? stats,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationSettingsState(
      isLoading: isLoading ?? this.isLoading,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyRemindersEnabled: dailyRemindersEnabled ?? this.dailyRemindersEnabled,
      overdueRemindersEnabled: overdueRemindersEnabled ?? this.overdueRemindersEnabled,
      streakRemindersEnabled: streakRemindersEnabled ?? this.streakRemindersEnabled,
      selectedTime: selectedTime ?? this.selectedTime,
      selectedDays: selectedDays ?? this.selectedDays,
      stats: stats ?? this.stats,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        notificationsEnabled,
        dailyRemindersEnabled,
        overdueRemindersEnabled,
        streakRemindersEnabled,
        selectedTime,
        selectedDays,
        stats,
        errorMessage,
      ];
}
