import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// A beautiful sync/backup dialog with Lottie animation
/// Following production app best practices
class SyncDialog extends StatelessWidget {
  final String title;
  final String? message;
  final bool showProgress;

  const SyncDialog({
    super.key,
    this.title = 'Syncing your data',
    this.message,
    this.showProgress = true,
  });

  /// Show the sync dialog
  static Future<void> show(
    BuildContext context, {
    String title = 'Syncing your data',
    String? message,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SyncDialog(
        title: title,
        message: message,
      ),
    );
  }

  /// Dismiss the sync dialog
  static void dismiss(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lottie animation - using a cloud upload animation from Lottie Files
            // In production, download and include the JSON file in assets
            // For now, we'll use a network URL (best practice is to use local assets)
            SizedBox(
              width: 150,
              height: 150,
              child: Lottie.network(
                'https://lottie.host/d5415b5f-05b5-4a8e-8ccf-6e4e3c3c5e8e/qlPFYQKZYz.json',
                fit: BoxFit.contain,
                // Fallback to a simple loading indicator if network fails
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.grey[900],
              ),
              textAlign: TextAlign.center,
            ),
            
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            if (showProgress) ...[
              const SizedBox(height: 24),
              // Linear progress indicator
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Success dialog to show after sync completes
class SyncSuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onDismiss;

  const SyncSuccessDialog({
    super.key,
    this.title = 'Sync Complete!',
    this.message = 'Your data has been successfully backed up to the cloud.',
    this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    String title = 'Sync Complete!',
    String message = 'Your data has been successfully backed up to the cloud.',
    VoidCallback? onDismiss,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => SyncSuccessDialog(
        title: title,
        message: message,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success animation
            SizedBox(
              width: 120,
              height: 120,
              child: Lottie.network(
                'https://lottie.host/647eb68e-e5a0-4145-b23a-f9a5b7a8c39e/6FyZKJCMNc.json',
                repeat: false,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.check_circle,
                    size: 80,
                    color: Colors.green[600],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.grey[900],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // OK button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onDismiss?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Got it!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
