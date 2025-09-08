import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/home_service.dart';
import '../../../../core/services/notification_service.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeService _homeService;

  HomeBloc({
    required HomeService homeService,
  })  : _homeService = homeService,
        super(const HomeState()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
    on<ToggleDeckFavorite>(_onToggleDeckFavorite);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
    on<DeleteNotification>(_onDeleteNotification);
  }

  Future<void> _onLoadHomeData(LoadHomeData event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final recentDecks = await _homeService.getRecentlyStudiedDecks();
      final dueCards = await _homeService.getDueCards();
      final recentSessions = await _homeService.getRecentStudySessions();
      final notifications = await NotificationService().getNotifications();
      final studyStats = await _homeService.getOverallStats();

      emit(state.copyWith(
        status: HomeStatus.success,
        recentDecks: recentDecks,
        dueCards: dueCards,
        recentSessions: recentSessions,
        notifications: notifications,
        studyStats: studyStats,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshHomeData(RefreshHomeData event, Emitter<HomeState> emit) async {
    emit(state.copyWith(isRefreshing: true));
    try {
      final recentDecks = await _homeService.getRecentlyStudiedDecks();
      final dueCards = await _homeService.getDueCards();
      final recentSessions = await _homeService.getRecentStudySessions();
      final notifications = await NotificationService().getNotifications();
      final studyStats = await _homeService.getOverallStats();

      emit(state.copyWith(
        isRefreshing: false,
        recentDecks: recentDecks,
        dueCards: dueCards,
        recentSessions: recentSessions,
        notifications: notifications,
        studyStats: studyStats,
      ));
    } catch (e) {
      emit(state.copyWith(
        isRefreshing: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onToggleDeckFavorite(ToggleDeckFavorite event, Emitter<HomeState> emit) async {
    try {
      await _homeService.toggleDeckFavorite(event.deckId);
      
      // Refresh the data to get updated favorites
      add(const RefreshHomeData());
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onMarkNotificationAsRead(MarkNotificationAsRead event, Emitter<HomeState> emit) async {
    try {
      await NotificationService().markNotificationAsRead(event.notificationId);
      
      final updatedNotifications = state.notifications.map((notification) {
        if (notification.id == event.notificationId) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();
      
      emit(state.copyWith(notifications: updatedNotifications));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onMarkAllNotificationsAsRead(MarkAllNotificationsAsRead event, Emitter<HomeState> emit) async {
    try {
      await NotificationService().markAllNotificationsAsRead();
      
      final updatedNotifications = state.notifications
          .map((notification) => notification.copyWith(isRead: true))
          .toList();
      
      emit(state.copyWith(notifications: updatedNotifications));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteNotification(DeleteNotification event, Emitter<HomeState> emit) async {
    try {
      await NotificationService().deleteNotification(event.notificationId);
      
      final updatedNotifications = state.notifications
          .where((notification) => notification.id != event.notificationId)
          .toList();
      
      emit(state.copyWith(notifications: updatedNotifications));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}

