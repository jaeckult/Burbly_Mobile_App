import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/core.dart';
import '../../../../core/services/adaptive_theme_service.dart';
import '../../../../core/services/onboarding_service.dart';
import '../../../auth/screens/home_screen.dart';
import '../../home/screens/flashcard_home_screen.dart';
import '../../notes/screens/notes_screen.dart';
import '../../notifications/screens/notification_settings_screen.dart';
import '../../../stats/screens/stats_page.dart';
import '../../trash/screens/trash_screen.dart' as trash_screen;
import '../../../testing/notification_test_screen.dart';
import '../../../testing/scheduling_debug_screen.dart';
import '../../../../core/widgets/profile_avatar.dart';

/// Extracted drawer widget for DeckPackListScreen
class DeckPackListDrawer extends StatelessWidget {
  final bool isGuestMode;
  final VoidCallback onSignInWithGoogle;
  final VoidCallback onBackupToCloud;
  final VoidCallback onSignOut;
  final VoidCallback onAbout;

  const DeckPackListDrawer({
    super.key,
    required this.isGuestMode,
    required this.onSignInWithGoogle,
    required this.onBackupToCloud,
    required this.onSignOut,
    required this.onAbout,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      child: SafeArea(
        child: Column(
          children: [
            // --- Header ---
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              margin: EdgeInsets.zero,
              currentAccountPicture: isGuestMode
                  ? const CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: Colors.grey),
                    )
                  : const UserProfileAvatar(
                      radius: 36,
                      backgroundColor: Colors.white,
                    ),
              accountName: Text(
                isGuestMode ? 'Guest User' : (user?.displayName ?? 'User'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                isGuestMode ? 'Offline mode' : (user?.email ?? ''),
                style: const TextStyle(fontSize: 13),
              ),
            ),

            // --- Drawer items ---
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text(
                      "Study",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.grey),
                    ),
                  ),
                  ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    leading: const Icon(Icons.home_outlined, size: 22, color: Colors.blue),
                    title: const Text('Deck Packs', style: TextStyle(fontSize: 14)),
                    onTap: () => Navigator.pop(context),
                  ),
                  ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    leading: const Icon(Icons.school_outlined, size: 22, color: Colors.green),
                    title: const Text('My Decks', style: TextStyle(fontSize: 14)),
                    onTap: () {
                      Navigator.pop(context);
                      context.pushFade(const FlashcardHomeScreen());
                    },
                  ),
                  ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    leading: const Icon(Icons.note_outlined, size: 22, color: Colors.orange),
                    title: const Text('Notes', style: TextStyle(fontSize: 14)),
                    onTap: () {
                      Navigator.pop(context);
                      context.pushFade(const NotesScreen());
                    },
                  ),
                  ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    leading: const Icon(Icons.analytics_outlined, size: 22, color: Colors.purple),
                    title: const Text('Statistics', style: TextStyle(fontSize: 14)),
                    onTap: () {
                      Navigator.pop(context);
                      context.pushFade(StatsPage());
                    },
                  ),
                  ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    leading: const Icon(Icons.notifications_outlined, size: 22, color: Colors.red),
                    title: const Text('Notification Settings', style: TextStyle(fontSize: 14)),
                    onTap: () {
                      Navigator.pop(context);
                      context.pushFade(const NotificationSettingsScreen());
                    },
                  ),
                  ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    leading: Icon(
                        AdaptiveThemeService.isDarkMode(context)
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                        size: 22,
                        color: AdaptiveThemeService.isDarkMode(context)
                            ? Colors.yellow[700]
                            : Colors.black),
                    title: Text(
                        AdaptiveThemeService.isDarkMode(context)
                            ? 'Light Mode'
                            : 'Dark Mode',
                        style: const TextStyle(fontSize: 14)),
                    onTap: () {
                      Navigator.pop(context);
                      AdaptiveThemeService.toggleTheme(context);
                    },
                  ),

                  const Divider(height: 1, thickness: 0.5),

                  // Development / Testing Section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      "Development",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.grey),
                    ),
                  ),
                  ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    leading: const Icon(Icons.science_outlined, size: 22, color: Colors.deepPurple),
                    title: const Text('Notification Tests', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('Test notification system', style: TextStyle(fontSize: 11)),
                    onTap: () {
                      Navigator.pop(context);
                      context.pushFade(const NotificationTestScreen());
                    },
                  ),
                  ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    leading: const Icon(Icons.bug_report, size: 22, color: Colors.orange),
                    title: const Text('Scheduling Debug', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('Debug scheduling issues', style: TextStyle(fontSize: 11)),
                    onTap: () {
                      Navigator.pop(context);
                      context.pushFade(const SchedulingDebugScreen());
                    },
                  ),
                  ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    leading: const Icon(Icons.refresh, size: 22, color: Colors.teal),
                    title: const Text('Reset Onboarding', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('Test onboarding flow', style: TextStyle(fontSize: 11)),
                    onTap: () async {
                      Navigator.pop(context);
                      await OnboardingService().resetAll();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Onboarding reset! Restart the app to see it again.'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                  ),

                  const Divider(height: 1, thickness: 0.5),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text(
                      "Account",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.grey),
                    ),
                  ),

                  if (isGuestMode)
                    ListTile(
                      dense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      leading: const Icon(Icons.cloud_sync_outlined,
                          size: 22, color: Colors.blueAccent),
                      title: const Text('Sign in with Google',
                          style: TextStyle(fontSize: 14)),
                      subtitle: const Text('Sync your data',
                          style: TextStyle(fontSize: 12)),
                      onTap: () {
                        Navigator.pop(context);
                        onSignInWithGoogle();
                      },
                    )
                  else ...[
                    ListTile(
                      dense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      leading: const Icon(Icons.backup_outlined,
                          size: 22, color: Colors.indigo),
                      title: const Text('Backup to Cloud',
                          style: TextStyle(fontSize: 14)),
                      subtitle: const Text('Sync your data',
                          style: TextStyle(fontSize: 12)),
                      onTap: () {
                        Navigator.pop(context);
                        onBackupToCloud();
                      },
                    ),
                    ListTile(
                      dense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      leading: const Icon(Icons.logout,
                          size: 22, color: Colors.redAccent),
                      title: const Text('Sign out', style: TextStyle(fontSize: 14)),
                      onTap: () {
                        Navigator.pop(context);
                        onSignOut();
                      },
                    ),
                  ],

                  const Divider(height: 1, thickness: 0.5),

                  ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    leading: const Icon(Icons.info_outline, size: 22, color: Colors.grey),
                    title: const Text('About', style: TextStyle(fontSize: 14)),
                    onTap: () {
                      Navigator.pop(context);
                      onAbout();
                    },
                  ),
                  ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    leading:
                        const Icon(Icons.delete_outline, size: 22, color: Colors.brown),
                    title: const Text('Trash', style: TextStyle(fontSize: 14)),
                    onTap: () {
                      Navigator.pop(context);
                      context.pushFade(const trash_screen.TrashScreen());
                    },
                  ),
                ],
              ),
            ),

            // --- Footer ---
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "v1.0.0",
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
