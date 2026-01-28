import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_strings.dart';
import '../constants/app_dimensions.dart';
import '../services/adaptive_theme_service.dart';
import '../widgets/profile_avatar.dart';

/// Shared app drawer used across multiple screens.
/// This eliminates ~290 lines of duplicate code per screen.
class AppDrawer extends StatelessWidget {
  final bool isGuestMode;
  final VoidCallback? onSignInWithGoogle;
  final VoidCallback? onBackupToCloud;
  final VoidCallback? onSignOut;
  final int? currentIndex;

  const AppDrawer({
    super.key,
    required this.isGuestMode,
    this.onSignInWithGoogle,
    this.onBackupToCloud,
    this.onSignOut,
    this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Drawer(
      width: MediaQuery.of(context).size.width * AppDimensions.drawerWidthRatio,
      child: SafeArea(
        child: Column(
          children: [
            _buildDrawerHeader(context, user),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildSectionHeader(AppStrings.study),
                  _buildNavigationTile(
                    context,
                    icon: Icons.home_outlined,
                    iconColor: Colors.blue,
                    title: AppStrings.deckPacks,
                    isSelected: currentIndex == 0,
                    routeName: '/home',
                  ),
                  _buildNavigationTile(
                    context,
                    icon: Icons.school_outlined,
                    iconColor: Colors.green,
                    title: AppStrings.myDecks,
                    isSelected: currentIndex == 1,
                    routeName: '/flashcards',
                  ),
                  _buildNavigationTile(
                    context,
                    icon: Icons.note_outlined,
                    iconColor: Colors.orange,
                    title: AppStrings.notes,
                    isSelected: currentIndex == 2,
                    routeName: '/notes',
                  ),
                  _buildNavigationTile(
                    context,
                    icon: Icons.analytics_outlined,
                    iconColor: Colors.purple,
                    title: AppStrings.statistics,
                    isSelected: currentIndex == 3,
                    routeName: '/stats',
                  ),
                  _buildNavigationTile(
                    context,
                    icon: Icons.notifications_outlined,
                    iconColor: Colors.red,
                    title: AppStrings.notifications,
                    isSelected: currentIndex == 4,
                    routeName: '/notifications',
                  ),
                  _buildThemeToggleTile(context),
                  const Divider(height: 1, thickness: 0.5),
                  _buildSectionHeader(AppStrings.account),
                  ..._buildAccountSection(context),
                  const Divider(height: 1, thickness: 0.5),
                  _buildNavigationTile(
                    context,
                    icon: Icons.info_outline,
                    iconColor: Colors.grey,
                    title: AppStrings.about,
                    onTap: () => _showAboutDialog(context),
                  ),
                  _buildNavigationTile(
                    context,
                    icon: Icons.delete_outline,
                    iconColor: Colors.brown,
                    title: AppStrings.trash,
                    routeName: '/trash',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingSm),
              child: Text(
                'v${AppStrings.appVersion}',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, User? user) {
    return UserAccountsDrawerHeader(
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
        isGuestMode ? AppStrings.guestUser : (user?.displayName ?? 'User'),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      accountEmail: Text(
        isGuestMode ? AppStrings.offlineMode : (user?.email ?? ''),
        style: const TextStyle(fontSize: 13),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingLg,
        vertical: AppDimensions.spacingXs,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildNavigationTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    String? routeName,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingLg,
        vertical: 0,
      ),
      leading: Icon(icon, size: 22, color: iconColor),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 12))
          : null,
      selected: isSelected,
      onTap: onTap ?? () {
        Navigator.pop(context);
        if (routeName != null) {
          Navigator.pushNamed(context, routeName);
        }
      },
    );
  }

  Widget _buildThemeToggleTile(BuildContext context) {
    final isDarkMode = AdaptiveThemeService.isDarkMode(context);
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingLg,
        vertical: 0,
      ),
      leading: Icon(
        isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
        size: 22,
        color: isDarkMode ? Colors.yellow[700] : Colors.black,
      ),
      title: Text(
        isDarkMode ? AppStrings.lightMode : AppStrings.darkMode,
        style: const TextStyle(fontSize: 14),
      ),
      onTap: () {
        Navigator.pop(context);
        AdaptiveThemeService.toggleTheme(context);
      },
    );
  }

  List<Widget> _buildAccountSection(BuildContext context) {
    if (isGuestMode) {
      return [
        ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingLg,
            vertical: 0,
          ),
          leading: const Icon(Icons.cloud_sync_outlined, size: 22, color: Colors.blueAccent),
          title: const Text(AppStrings.signInWithGoogle, style: TextStyle(fontSize: 14)),
          subtitle: const Text(AppStrings.syncYourData, style: TextStyle(fontSize: 12)),
          onTap: () {
            Navigator.pop(context);
            onSignInWithGoogle?.call();
          },
        ),
      ];
    } else {
      return [
        ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingLg,
            vertical: 0,
          ),
          leading: const Icon(Icons.backup_outlined, size: 22, color: Colors.indigo),
          title: const Text(AppStrings.backupToCloud, style: TextStyle(fontSize: 14)),
          subtitle: const Text(AppStrings.syncYourData, style: TextStyle(fontSize: 12)),
          onTap: () {
            Navigator.pop(context);
            onBackupToCloud?.call();
          },
        ),
        ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingLg,
            vertical: 0,
          ),
          leading: const Icon(Icons.logout, size: 22, color: Colors.redAccent),
          title: const Text(AppStrings.signOutButton, style: TextStyle(fontSize: 14)),
          onTap: () {
            Navigator.pop(context);
            onSignOut?.call();
          },
        ),
      ];
    }
  }

  void _showAboutDialog(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.school, size: 36, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            const Text('Burbly Flashcard'),
          ],
        ),
        content: Text(
          'Version ${AppStrings.appVersion}\n\n${AppStrings.appDescription}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
