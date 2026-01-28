/// Centralized string constants for the Burbly app.
/// This serves as a foundation for future internationalization (i18n).
class AppStrings {
  AppStrings._();

  // App Info
  static const String appName = 'Burbly';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'A smart flashcard app that works offline and syncs your data when you sign in.';

  // Auth Screens
  static const String welcomeTitle = 'Welcome to Burbly';
  static const String loginTitle = 'Sign In';
  static const String signupTitle = 'Create Account';
  static const String joinBurbly = 'Join Burbly';
  static const String createAccountSubtitle = 'Create your account to get started';
  static const String emailLabel = 'Email';
  static const String emailHint = 'Enter your email';
  static const String passwordLabel = 'Password';
  static const String passwordHint = 'Enter your password';
  static const String confirmPasswordLabel = 'Confirm Password';
  static const String confirmPasswordHint = 'Confirm your password';
  static const String createAccountButton = 'Create Account';
  static const String signInButton = 'Sign In';
  static const String signOutButton = 'Sign out';
  static const String continueWithGoogle = 'Continue with Google';
  static const String signInWithGoogle = 'Sign in with Google';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String dontHaveAccount = "Don't have an account?";
  static const String privacyPolicyText = 'By signing up, you agree to our ';
  static const String privacyPolicyLink = 'Privacy Policy';
  static const String or = 'OR';

  // Validation Messages
  static const String emailRequired = 'Please enter your email';
  static const String emailInvalid = 'Please enter a valid email';
  static const String passwordRequired = 'Please enter your password';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String confirmPasswordRequired = 'Please confirm your password';
  static const String passwordsDoNotMatch = 'Passwords do not match';

  // Navigation & Drawer
  static const String myDecks = 'My Decks';
  static const String deckPacks = 'Deck Packs';
  static const String notes = 'Notes';
  static const String statistics = 'Statistics';
  static const String notifications = 'Notifications';
  static const String trash = 'Trash';
  static const String about = 'About';
  static const String study = 'Study';
  static const String account = 'Account';
  static const String lightMode = 'Light Mode';
  static const String darkMode = 'Dark Mode';

  // Deck & Flashcard
  static const String createDeck = 'Create Deck';
  static const String editDeck = 'Edit Deck';
  static const String deleteDeck = 'Delete Deck';
  static const String noDeckYet = 'No decks yet';
  static const String createFirstDeck = 'Create your first deck to get started';
  static const String cards = 'cards';
  static const String addFlashcard = 'Add Flashcard';
  static const String editFlashcard = 'Edit Flashcard';
  static const String deleteFlashcard = 'Delete Flashcard';
  static const String question = 'Question';
  static const String answer = 'Answer';
  static const String description = 'Description';

  // Study
  static const String startStudying = 'Start Studying';
  static const String mixedStudy = 'Mixed Study';
  static const String studyReminder = 'Study Reminder';
  static const String timeToStudy = 'Time to Study! 📚';
  static const String flashcardsWaiting = 'You have flashcards waiting for review. Keep your streak going!';
  static const String noCardsToStudy = 'Add some flashcards to start studying!';
  static const String studyTimer = 'Study Timer';
  static const String spacedRepetition = 'Spaced Repetition';
  static const String showStudyStats = 'Show Study Stats';

  // Status & Notifications
  static const String success = 'Success';
  static const String error = 'Error';
  static const String warning = 'Warning';
  static const String info = 'Info';
  static const String loading = 'Loading...';
  static const String backingUp = 'Backing up your data...';
  static const String backupSuccess = 'Backup completed successfully!';
  static const String backupFailed = 'Backup failed';
  static const String signInSuccess = 'Successfully signed in! Use the backup button to sync your data.';
  static const String signInFailed = 'Sign-in failed';
  static const String signOutSuccess = 'Signed out successfully';
  static const String signOutFailed = 'Sign-out failed';

  // Actions
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String confirm = 'Confirm';
  static const String today = 'Today';
  static const String daysAgo = 'd ago';

  // Guest Mode
  static const String guestUser = 'Guest User';
  static const String offlineMode = 'Offline mode';
  static const String syncYourData = 'Sync your data';
  static const String backupToCloud = 'Backup to Cloud';

  // Confirmation Messages
  static const String deleteConfirmTitle = 'Delete';
  static const String deleteDeckConfirm = 'Are you sure you want to delete this deck? This action cannot be undone.';
  static const String deleteFlashcardConfirm = 'Are you sure you want to delete this flashcard?';
  static const String movedToTrash = 'moved to Trash';

  // Pet Notifications
  static const String petMissesYou = 'Your Pet Misses You! 🐾';

  // Streak
  static const String amazingStreak = 'Amazing Streak! 🔥';
  static String streakMessage(int days) => "You've studied for $days days in a row! Keep it up!";

  // Errors
  static const String initializationError = 'Error during app initialization';
  static const String dataServiceNotInitialized = 'DataService has not been initialized. Please call initialize() first.';
  static const String boxesNotAccessible = 'DataService has not been initialized or boxes are not accessible.';
  static const String signInRequired = 'You must be signed in to backup your data.';
}
