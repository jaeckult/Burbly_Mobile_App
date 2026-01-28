/// Centralized dimension constants for the Burbly app.
/// Using these instead of magic numbers throughout the codebase.
class AppDimensions {
  AppDimensions._();

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 20.0;
  static const double spacingXxl = 24.0;
  static const double spacingXxxl = 32.0;

  // Border Radius
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusXxl = 20.0;
  static const double radiusCircular = 100.0;

  // Icon Sizes
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;
  static const double iconXxl = 40.0;
  static const double iconHero = 80.0;

  // Button Heights
  static const double buttonHeightSm = 36.0;
  static const double buttonHeightMd = 44.0;
  static const double buttonHeightLg = 52.0;

  // Card Dimensions
  static const double cardElevation = 3.0;
  static const double cardElevationHigh = 6.0;

  // Drawer
  static const double drawerWidthRatio = 0.75;

  // Grid
  static const int gridCrossAxisCount = 2;
  static const double gridCrossAxisSpacing = 16.0;
  static const double gridMainAxisSpacing = 16.0;
  static const double gridChildAspectRatio = 0.75;

  // Responsive Breakpoints
  static const double breakpointMobile = 600.0;
  static const double breakpointTablet = 900.0;
  static const double breakpointDesktop = 1200.0;

  // Spaced Repetition Constants
  static const double minEaseFactor = 1.3;
  static const double maxEaseFactor = 2.5;
  static const double defaultEaseFactor = 2.5;
  static const int initialInterval = 1;
  static const int firstSuccessInterval = 6;

  // Timer Defaults
  static const int defaultTimerDuration = 30;
  static const List<int> quickTimerOptions = [1, 3, 10, 15, 30, 45, 60, 90, 120];

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 200);
  static const Duration animationSlow = Duration(milliseconds: 300);
  static const Duration animationVerySlow = Duration(milliseconds: 500);

  // Notification IDs
  static const int dailyReminderId = 1000;
  static const int overdueCardsId = 2000;
  static const int studyStreakId = 3000;

  // Refresh Intervals
  static const Duration refreshInterval = Duration(seconds: 30);
  static const Duration overdueCheckInterval = Duration(hours: 2);
  static const Duration streakReminderDelay = Duration(hours: 1);
}
