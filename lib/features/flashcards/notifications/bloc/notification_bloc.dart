import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/models/flashcard.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationService notificationService;
  Timer? _timer;

  NotificationBloc(this.notificationService) : super(const NotificationState()) {
    on<LoadNotificationData>(_onLoad);
    on<PeriodicRefresh>(_onPeriodicRefresh);
    on<DismissForHours>(_onDismissForHours);
    on<StartAutomaticStudyRequested>(_onStartStudy);

    // start periodic timer (5 minutes)
    _timer = Timer.periodic(const Duration(minutes: 5), (_) => add(const PeriodicRefresh()));
  }

  Future<void> _onLoad(LoadNotificationData event, Emitter<NotificationState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true, startReview: false));
    try {
      final prefs = await SharedPreferences.getInstance();
      final dismissedUntilStr = prefs.getString('notification_widget_dismissed_until');
      DateTime? dismissedUntil;
      if (dismissedUntilStr != null) {
        try {
          dismissedUntil = DateTime.parse(dismissedUntilStr);
        } catch (_) {
          await prefs.remove('notification_widget_dismissed_until');
        }
      }

      if (dismissedUntil != null && DateTime.now().isBefore(dismissedUntil)) {
        emit(state.copyWith(
          isLoading: false,
          dismissedUntil: dismissedUntil,
          overdueCount: 0,
          dueTodayCount: 0,
        ));
        return;
      }

      final List<Flashcard> overdue = await notificationService.getOverdueCards();
      final List<Flashcard> dueToday = await notificationService.getCardsDueToday();

      if (overdue.isNotEmpty || dueToday.isNotEmpty) {
        await notificationService.showStudyReminderNotification(
          overdue.isNotEmpty ? 'Cards Need Review! ⚠️' : 'Study Reminder 📚',
          overdue.isNotEmpty
              ? '${overdue.length} cards are overdue for review. Time to catch up!'
              : '${dueToday.length} cards are due for review today.',
        );
      }

      emit(state.copyWith(
        isLoading: false,
        dismissedUntil: null,
        overdueCount: overdue.length,
        dueTodayCount: dueToday.length,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Failed to load notification data: $e'));
    }
  }

  Future<void> _onPeriodicRefresh(PeriodicRefresh event, Emitter<NotificationState> emit) async {
    // Just reuse load
    await _onLoad(const LoadNotificationData(), emit);
  }

  Future<void> _onDismissForHours(DismissForHours event, Emitter<NotificationState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final until = DateTime.now().add(Duration(hours: event.hours));
      await prefs.setString('notification_widget_dismissed_until', until.toIso8601String());
      emit(state.copyWith(
        dismissedUntil: until,
        overdueCount: 0,
        dueTodayCount: 0,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to dismiss: $e'));
    }
  }

  Future<void> _onStartStudy(StartAutomaticStudyRequested event, Emitter<NotificationState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final until = DateTime.now().add(const Duration(hours: 4));
      await prefs.setString('notification_widget_dismissed_until', until.toIso8601String());
      emit(state.copyWith(
        dismissedUntil: until,
        overdueCount: 0,
        dueTodayCount: 0,
        startReview: true,
      ));
      // reset the one-shot flag
      emit(state.copyWith(startReview: false));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to start review: $e'));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
