import 'package:flutter/foundation.dart';

/// Simple logging utility to replace scattered print statements.
/// In debug mode, logs are printed. In release mode, they're suppressed.
class AppLogger {
  AppLogger._();

  static const String _tag = 'Burbly';

  /// Log debug information (development only)
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? '/$tag' : ''}] DEBUG: $message');
    }
  }

  /// Log informational messages
  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? '/$tag' : ''}] INFO: $message');
    }
  }

  /// Log warnings
  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? '/$tag' : ''}] ⚠️ WARNING: $message');
    }
  }

  /// Log errors with optional stack trace
  static void error(String message, {dynamic error, StackTrace? stackTrace, String? tag}) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? '/$tag' : ''}] ❌ ERROR: $message');
      if (error != null) {
        debugPrint('  Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('  Stack trace:\n$stackTrace');
      }
    }
  }

  /// Log success messages
  static void success(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? '/$tag' : ''}] ✅ SUCCESS: $message');
    }
  }

  /// Log data integrity checks
  static void dataIntegrity(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? '/$tag' : ''}] 📊 DATA: $message');
    }
  }

  /// Log notification events
  static void notification(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? '/$tag' : ''}] 🔔 NOTIFICATION: $message');
    }
  }

  /// Log study/learning events
  static void study(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? '/$tag' : ''}] 📚 STUDY: $message');
    }
  }

  /// Log sync/backup operations
  static void sync(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? '/$tag' : ''}] ☁️ SYNC: $message');
    }
  }
}
