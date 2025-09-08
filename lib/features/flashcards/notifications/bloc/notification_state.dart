import 'package:equatable/equatable.dart';

class NotificationState extends Equatable {
  final bool isLoading;
  final int overdueCount;
  final int dueTodayCount;
  final DateTime? dismissedUntil;
  final String? errorMessage;
  final bool startReview; // one-shot trigger

  const NotificationState({
    this.isLoading = false,
    this.overdueCount = 0,
    this.dueTodayCount = 0,
    this.dismissedUntil,
    this.errorMessage,
    this.startReview = false,
  });

  bool get isDismissedNow => dismissedUntil != null && DateTime.now().isBefore(dismissedUntil!);
  bool get hasAnyDue => overdueCount > 0 || dueTodayCount > 0;

  NotificationState copyWith({
    bool? isLoading,
    int? overdueCount,
    int? dueTodayCount,
    DateTime? dismissedUntil,
    String? errorMessage,
    bool? startReview,
    bool clearError = false,
    bool clearDismissal = false,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      overdueCount: overdueCount ?? this.overdueCount,
      dueTodayCount: dueTodayCount ?? this.dueTodayCount,
      dismissedUntil: clearDismissal ? null : (dismissedUntil ?? this.dismissedUntil),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      startReview: startReview ?? false,
    );
  }

  @override
  List<Object?> get props => [isLoading, overdueCount, dueTodayCount, dismissedUntil, errorMessage, startReview];
}
