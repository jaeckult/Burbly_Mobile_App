import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/data_service.dart';
import '../services/notification_service.dart';
import '../services/background_service.dart';
import '../services/pet_service.dart';
import '../services/study_service.dart';
import '../services/fsrs_study_service.dart';
import '../services/overdue_service.dart';
import '../services/deck_scheduling_service.dart';
import '../services/user_profile_service.dart';
import '../services/adaptive_theme_service.dart';
import '../services/onboarding_service.dart';
import '../../features/auth/services/auth_service.dart';
import '../services/local_storage_service.dart';
import '../services/sync_service.dart';
import '../services/stats_service.dart';
import '../services/search_service.dart';
import '../services/trash_service.dart';
import '../repositories/deck_repository.dart';
import '../repositories/flashcard_repository.dart';
import '../repositories/deck_pack_repository.dart';
import '../repositories/note_repository.dart';
import '../repositories/study_session_repository.dart';
import '../repositories/trash_repository.dart';
import '../repositories/notification_repository.dart';
import '../services/reminder_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Global service locator instance.
/// Use this to access registered services throughout the app.
final GetIt locator = GetIt.instance;

/// Sets up all dependency injection registrations.
/// Call this once during app startup before runApp().
Future<void> setupServiceLocator() async {
  // External dependencies
  locator.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  locator.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Core Services - Lazy singletons (created on first use)
  locator.registerLazySingleton<DataService>(() => DataService());
  locator.registerLazySingleton<NotificationService>(() => NotificationService());
  locator.registerLazySingleton<BackgroundService>(() => BackgroundService());
  locator.registerLazySingleton<PetService>(() => PetService());
  locator.registerLazySingleton<StudyService>(() => StudyService());
  locator.registerLazySingleton<FSRSStudyService>(() => FSRSStudyService());
  locator.registerLazySingleton<OverdueService>(() => OverdueService());
  locator.registerLazySingleton<DeckSchedulingService>(() => DeckSchedulingService());
  locator.registerLazySingleton<UserProfileService>(() => UserProfileService());
  locator.registerLazySingleton<AdaptiveThemeService>(() => AdaptiveThemeService());
  
  // Storage & Repositories
  locator.registerLazySingleton<LocalStorageService>(() => LocalStorageService());
  locator.registerLazySingleton<DeckRepository>(() => DeckRepository(storage: locator<LocalStorageService>()));
  locator.registerLazySingleton<FlashcardRepository>(() => FlashcardRepository(storage: locator<LocalStorageService>()));
  locator.registerLazySingleton<DeckPackRepository>(() => DeckPackRepository(storage: locator<LocalStorageService>()));
  locator.registerLazySingleton<NoteRepository>(() => NoteRepository(storage: locator<LocalStorageService>()));
  locator.registerLazySingleton<StudySessionRepository>(() => StudySessionRepository(storage: locator<LocalStorageService>()));
  locator.registerLazySingleton<TrashRepository>(() => TrashRepository(storage: locator<LocalStorageService>()));
  
  // Sync & Search Services
  locator.registerLazySingleton<SyncService>(() => SyncService(
    firestore: locator<FirebaseFirestore>(),
    auth: locator<FirebaseAuth>(),
    deckRepository: locator<DeckRepository>(),
    flashcardRepository: locator<FlashcardRepository>(),
    deckPackRepository: locator<DeckPackRepository>(),
    noteRepository: locator<NoteRepository>(),
    studySessionRepository: locator<StudySessionRepository>(),
    trashRepository: locator<TrashRepository>(),
  ));

  locator.registerLazySingleton<StatsService>(() => StatsService(
    deckRepository: locator<DeckRepository>(),
    sessionRepository: locator<StudySessionRepository>(),
  ));

  locator.registerLazySingleton<SearchService>(() => SearchService(
    deckRepository: locator<DeckRepository>(),
    flashcardRepository: locator<FlashcardRepository>(),
    noteRepository: locator<NoteRepository>(),
  ));

  locator.registerLazySingleton<TrashService>(() => TrashService(
    trashRepo: locator<TrashRepository>(),
    deckRepo: locator<DeckRepository>(),
    flashcardRepo: locator<FlashcardRepository>(),
    deckPackRepo: locator<DeckPackRepository>(),
    noteRepo: locator<NoteRepository>(),
  ));

  locator.registerLazySingleton<NotificationRepository>(() => NotificationRepository());
  
  // Reminder Service registration needs localized timezone which is managed by NotificationService
  // but for DI, we can register it once NotificationService is initialized.
  // Or just register it as a lazy singleton.
  locator.registerLazySingleton<ReminderService>(() => ReminderService(
    notifications: FlutterLocalNotificationsPlugin(),
    repository: locator<NotificationRepository>(),
    detectedTimezone: () => tz.local, // Fallback, override in NotificationService init if needed
  ));

  // Auth Services
  locator.registerLazySingleton<AuthService>(() => AuthService());
  
  // Onboarding Service
  locator.registerLazySingleton<OnboardingService>(() => OnboardingService());
}

/// Resets the service locator (useful for testing).
Future<void> resetServiceLocator() async {
  await locator.reset();
}

/// Extension to easily access services from GetIt.
extension ServiceLocatorExtension on GetIt {
  // Core services
  DataService get dataService => get<DataService>();
  NotificationService get notificationService => get<NotificationService>();
  BackgroundService get backgroundService => get<BackgroundService>();
  PetService get petService => get<PetService>();
  StudyService get studyService => get<StudyService>();
  FSRSStudyService get fsrsStudyService => get<FSRSStudyService>();
  OverdueService get overdueService => get<OverdueService>();
  DeckSchedulingService get deckSchedulingService => get<DeckSchedulingService>();
  UserProfileService get userProfileService => get<UserProfileService>();
  LocalStorageService get localStorageService => get<LocalStorageService>();
  SyncService get syncService => get<SyncService>();
  
  // Repositories
  DeckRepository get deckRepository => get<DeckRepository>();
  FlashcardRepository get flashcardRepository => get<FlashcardRepository>();
  DeckPackRepository get deckPackRepository => get<DeckPackRepository>();
  NoteRepository get noteRepository => get<NoteRepository>();
  StudySessionRepository get studySessionRepository => get<StudySessionRepository>();
  TrashRepository get trashRepository => get<TrashRepository>();
  TrashService get trashService => get<TrashService>();
  
  // Auth services
  AuthService get authService => get<AuthService>();
  
  // Firebase instances
  FirebaseAuth get firebaseAuth => get<FirebaseAuth>();
  FirebaseFirestore get firestore => get<FirebaseFirestore>();
  
  // Onboarding service
  OnboardingService get onboardingService => get<OnboardingService>();
}
