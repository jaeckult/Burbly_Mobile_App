import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage onboarding and walkthrough completion state
class OnboardingService {
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyWalkthroughPrefix = 'walkthrough_completed_';

  /// Check if onboarding has been completed
  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingCompleted, true);
  }

  /// Check if walkthrough has been completed for a specific screen
  Future<bool> isWalkthroughCompleted(String screenName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_keyWalkthroughPrefix$screenName') ?? false;
  }

  /// Mark walkthrough as completed for a specific screen
  Future<void> completeWalkthrough(String screenName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_keyWalkthroughPrefix$screenName', true);
  }

  /// Reset onboarding completion (for testing/debugging)
  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingCompleted, false);
  }

  /// Reset walkthrough completion for a specific screen (for testing/debugging)
  Future<void> resetWalkthrough(String screenName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_keyWalkthroughPrefix$screenName', false);
  }

  /// Reset all onboarding and walkthrough data (for testing/debugging)
  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingCompleted, false);
    
    // Reset all walkthrough keys
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_keyWalkthroughPrefix)) {
        await prefs.remove(key);
      }
    }
  }
}
