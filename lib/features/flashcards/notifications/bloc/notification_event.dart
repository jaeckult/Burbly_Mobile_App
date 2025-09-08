import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

class LoadNotificationData extends NotificationEvent {
  const LoadNotificationData();
}

class PeriodicRefresh extends NotificationEvent {
  const PeriodicRefresh();
}

class DismissForHours extends NotificationEvent {
  final int hours;
  const DismissForHours(this.hours);
  @override
  List<Object?> get props => [hours];
}

class StartAutomaticStudyRequested extends NotificationEvent {
  const StartAutomaticStudyRequested();
}
