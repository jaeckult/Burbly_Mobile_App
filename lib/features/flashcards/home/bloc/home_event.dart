import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeData extends HomeEvent {
  const LoadHomeData();
}

class RefreshHomeData extends HomeEvent {
  const RefreshHomeData();
}

class ToggleDeckFavorite extends HomeEvent {
  final String deckId;

  const ToggleDeckFavorite(this.deckId);

  @override
  List<Object?> get props => [deckId];
}

class MarkNotificationAsRead extends HomeEvent {
  final String notificationId;

  const MarkNotificationAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllNotificationsAsRead extends HomeEvent {
  const MarkAllNotificationsAsRead();
}

class DeleteNotification extends HomeEvent {
  final String notificationId;

  const DeleteNotification(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

