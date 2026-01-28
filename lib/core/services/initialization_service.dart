import 'package:flutter/foundation.dart';
import '../di/service_locator.dart';
import '../utils/logger.dart';
import './performance_service.dart';

/// Service to coordinate async initialization of app services
/// This allows the app to start quickly and initialize services in the background
class InitializationService {
  static final InitializationService _instance = InitializationService._internal();
  factory InitializationService() => _instance;
  InitializationService._internal();

  bool _isInitialized = false;
  bool _isInitializing = false;
  final List<String> _initializedServices = [];
  final Map<String, dynamic> _errors = {};

  bool get isInitialized => _isInitialized;
  bool get isInitializing => _isInitializing;
  List<String> get initializedServices => List.unmodifiable(_initializedServices);
  Map<String, dynamic> get errors => Map.unmodifiable(_errors);

  /// Initialize all non-critical services in the background
  /// This is called after the app UI is shown
  Future<void> initializeServices() async {
    if (_isInitialized || _isInitializing) return;
    
    _isInitializing = true;
    AppLogger.info('Starting background service initialization');

    try {
      // Initialize data service (critical for app functionality)
      await _initializeService('DataService', () async {
        final dataService = locator.dataService;
        if (!dataService.isInitialized) {
          await dataService.initialize();
        }
      });

      // Initialize notification service (can fail gracefully)
      await _initializeService('NotificationService', () async {
        try {
          await locator.notificationService.initialize();
        } catch (e) {
          AppLogger.warning('Notification service failed to initialize: $e');
          // Continue without notifications
        }
      });

      // Initialize pet service
      await _initializeService('PetService', () async {
        try {
          await locator.petService.initialize();
        } catch (e) {
          AppLogger.warning('Pet service failed to initialize: $e');
        }
      });

      // Start background service (can fail gracefully)
      await _initializeService('BackgroundService', () async {
        try {
          await locator.backgroundService.start();
        } catch (e) {
          AppLogger.warning('Background service failed to start: $e');
        }
      });

      // Start performance monitoring
      await _initializeService('PerformanceService', () async {
        PerformanceService().startMonitoring();
      });

      _isInitialized = true;
      AppLogger.success('All services initialized successfully');
    } catch (e) {
      AppLogger.error('Error during service initialization', error: e);
      _isInitialized = true; // Mark as complete even with errors
    } finally {
      _isInitializing = false;
    }
  }

  /// Initialize a single service with error handling and logging
  Future<void> _initializeService(String serviceName, Future<void> Function() initializer) async {
    try {
      final stopwatch = Stopwatch()..start();
      await initializer();
      stopwatch.stop();
      
      _initializedServices.add(serviceName);
      AppLogger.success('$serviceName initialized in ${stopwatch.elapsedMilliseconds}ms');
    } catch (e) {
      _errors[serviceName] = e.toString();
      AppLogger.error('Failed to initialize $serviceName', error: e);
      rethrow;
    }
  }

  /// Verify data integrity in the background (non-blocking)
  Future<void> verifyDataIntegrity() async {
    try {
      final dataService = locator.dataService;
      if (dataService.isInitialized) {
        final integrityCheck = await dataService.checkDataIntegrity();
        AppLogger.dataIntegrity('Data integrity check completed: ${integrityCheck['status']}');
      }
    } catch (e) {
      AppLogger.warning('Could not verify data integrity: $e');
    }
  }

  /// Get initialization progress (0.0 to 1.0)
  double getProgress() {
    const totalServices = 4; // DataService, NotificationService, PetService, BackgroundService
    return _initializedServices.length / totalServices;
  }

  /// Reset initialization state (for testing)
  @visibleForTesting
  void reset() {
    _isInitialized = false;
    _isInitializing = false;
    _initializedServices.clear();
    _errors.clear();
  }
}
