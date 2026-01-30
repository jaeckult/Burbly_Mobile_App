import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'firebase_options.dart';
import 'features/auth/screens/welcome_screen.dart';
import 'features/flashcards/deck_list/view/deck_pack_list_screen.dart';
import 'features/flashcards/home/screens/flashcard_home_screen.dart';
import 'features/auth/screens/privacy_policy_screen.dart';
import 'core/core.dart';
import 'core/services/adaptive_theme_service.dart';
import 'core/services/initialization_service.dart';
import 'core/animations/page_transitions.dart';
import 'core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/flashcards/study/screens/mixed_study_screen.dart';
import 'features/flashcards/deck_detail/view/deck_detail_screen.dart';
import 'features/flashcards/notes/screens/notes_screen.dart';
import 'features/flashcards/notifications/screens/notification_settings_screen.dart';
import 'features/flashcards/trash/screens/trash_screen.dart';
import 'features/stats/screens/stats_page.dart';
import 'core/services/native_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // CRITICAL ONLY: Initialize Firebase and service locator
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    await setupServiceLocator();
    AppLogger.info('Service locator initialized');
    
    // Initialize new native notification system
    await NativeNotificationService.initialize();
    AppLogger.info('Native notification service initialized');
    
    // Show UI immediately - other services initialize in background
    runApp(const MyApp());
  } catch (e) {
    AppLogger.error('Error during critical initialization', error: e);
    // Still run the app even if initialization fails
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: AdaptiveThemeService.lightTheme,
      dark: AdaptiveThemeService.darkTheme,
      initial: AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(locator.authService),
          ),
        ],
        child: MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          // Apply global page transitions for consistent motion
          theme: theme.copyWith(
            pageTransitionsTheme: AppPageTransitions.theme,
          ),
          darkTheme: darkTheme.copyWith(
            pageTransitionsTheme: AppPageTransitions.theme,
          ),
          navigatorKey: locator.notificationService.navigatorKey,
          home: const _RootScreen(),
          onGenerateRoute: (settings) {
            // Home and main screens
            if (settings.name == '/home') {
              return MaterialPageRoute(builder: (_) => const DeckPackListScreen());
            }
            if (settings.name == '/flashcards') {
              return MaterialPageRoute(builder: (_) => const FlashcardHomeScreen());
            }
            
            // Study screens
            if (settings.name == '/study-mixed') {
              return MaterialPageRoute(builder: (_) => const MixedStudyScreen());
            }
            if (settings.name == '/deck-detail') {
              final args = settings.arguments as Map<String, dynamic>?;
              final deck = args?['deck'] as Deck?;
              if (deck != null) {
                return MaterialPageRoute(builder: (_) => DeckDetailScreen(deck: deck));
              }
            }
            
            // Feature screens
            if (settings.name == '/notes') {
              return MaterialPageRoute(builder: (_) => const NotesScreen());
            }
            if (settings.name == '/stats') {
              return MaterialPageRoute(builder: (_) => StatsPage());
            }
            if (settings.name == '/notifications') {
              return MaterialPageRoute(builder: (_) => const NotificationSettingsScreen());
            }
            if (settings.name == '/trash') {
              return MaterialPageRoute(builder: (_) => const TrashScreen());
            }
            if (settings.name == '/deck-packs') {
              return MaterialPageRoute(builder: (_) => const DeckPackListScreen());
            }
            
            // Auth screens
            if (settings.name == '/privacy') {
              return MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen());
            }
            
            return null;
          },
          routes: {
            '/transitions': (context) => const TransitionDemoScreen(),
          },
        ),
      ),
    );
  }
}

class _RootScreen extends StatefulWidget {
  const _RootScreen({Key? key}) : super(key: key);

  @override
  State<_RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<_RootScreen> {
  late Future<Widget> _screenFuture;
  final _initService = InitializationService();

  @override
  void initState() {
    super.initState();
    _screenFuture = _decideStartScreen();
    // Initialize services in background (non-blocking)
    _initService.initializeServices().then((_) {
      // Verify data integrity after services are ready
      _initService.verifyDataIntegrity();
    });
  }

  Future<Widget> _decideStartScreen() async {
    try {
      // Add timeout to prevent indefinite loading
      final prefs = await SharedPreferences.getInstance()
          .timeout(const Duration(seconds: 2));
      
      final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
      final isGuestMode = prefs.getBool('isGuestMode') ?? false;
      final currentUser = locator.firebaseAuth.currentUser;

      // Only show welcome/login on fresh install; otherwise go straight to home
      if (isFirstLaunch) {
        return const WelcomeScreen();
      } else if (!isGuestMode && currentUser == null) {
        return const WelcomeScreen();
      } else {
        return const DeckPackListScreen();
      }
    } catch (e) {
      AppLogger.warning('Error deciding start screen, defaulting to home: $e');
      // Fallback to home on timeout or error
      return const DeckPackListScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _screenFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!;
        }
        
        // Show loading screen while deciding
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.backgroundLight, 
                  AppColors.surfaceVariantLight,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school,
                    size: AppDimensions.iconHero,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),
                  Text(
                    AppStrings.appName,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: AppColors.textPrimaryLight,
                    ) ?? const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXl),
                  const CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
