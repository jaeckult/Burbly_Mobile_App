import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import '../utils/logger.dart';

/// Service for monitoring app performance metrics
class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  final List<FrameTiming> _timings = [];
  bool _isMonitoring = false;
  bool _warmupComplete = false;
  int _framesSinceStart = 0;
  
  // Performance targets
  static const double _targetFrameTimeMs = 16.67; // 60 FPS
  static const int _warmupFrames = 60; // Ignore first 60 frames (approx 1 second)
  static const int _minSampleSize = 10; // Minimum frames before reporting
  static const double _jankThreshold = 30.0; // Only warn above 30%
  
  /// Start monitoring frame timings
  void startMonitoring() {
    if (_isMonitoring) return;
    _isMonitoring = true;
    _warmupComplete = false;
    _framesSinceStart = 0;
    _timings.clear();
    
    // Register frame timing callback
    PlatformDispatcher.instance.onReportTimings = _onReportTimings;
    AppLogger.info('Performance monitoring started (warmup: $_warmupFrames frames)');
  }

  /// Stop monitoring frame timings
  void stopMonitoring() {
    _isMonitoring = false;
    PlatformDispatcher.instance.onReportTimings = null;
    AppLogger.info('Performance monitoring stopped');
  }

  void _onReportTimings(List<FrameTiming> timings) {
    if (!_isMonitoring) return;
    
    _framesSinceStart += timings.length;
    
    // Skip warmup frames (initial load is expected to be janky)
    if (!_warmupComplete) {
      if (_framesSinceStart >= _warmupFrames) {
        _warmupComplete = true;
        AppLogger.info('Performance warmup complete, now monitoring');
      }
      return;
    }
    
    _timings.addAll(timings);
    
    // Keep only last 1000 frames for analysis
    if (_timings.length > 1000) {
      _timings.removeRange(0, _timings.length - 1000);
    }
    
    // Periodically log performance if jank is detected
    _checkForJank(timings);
  }

  void _checkForJank(List<FrameTiming> timings) {
    // Need minimum sample size to report
    if (timings.length < _minSampleSize) return;
    
    int jankyFrames = 0;
    for (final timing in timings) {
      if (timing.totalSpan.inMicroseconds > _targetFrameTimeMs * 1000) {
        jankyFrames++;
      }
    }
    
    if (jankyFrames > 0) {
      final percentage = (jankyFrames / timings.length) * 100;
      // Only warn if above threshold and have enough samples
      if (percentage > _jankThreshold) {
        AppLogger.warning('High jank detected: ${percentage.toStringAsFixed(1)}% of frames were janky');
      }
    }
  }

  /// Get current performance metrics
  Map<String, dynamic> getMetrics() {
    if (_timings.isEmpty) return {'status': 'no data'};
    
    final durations = _timings.map((t) => t.totalSpan.inMicroseconds / 1000).toList();
    durations.sort();
    
    final median = durations[durations.length ~/ 2];
    final p95 = durations[(durations.length * 0.95).toInt()];
    final p99 = durations[(durations.length * 0.99).toInt()];
    
    int jankyFrames = durations.where((d) => d > _targetFrameTimeMs).length;
    double jankPercentage = (jankyFrames / durations.length) * 100;

    return {
      'sampleSize': durations.length,
      'medianFrameTimeMs': median.toStringAsFixed(2),
      'p95FrameTimeMs': p95.toStringAsFixed(2),
      'p99FrameTimeMs': p99.toStringAsFixed(2),
      'jankPercentage': jankPercentage.toStringAsFixed(1),
      'status': jankPercentage < 5 ? 'healthy' : (jankPercentage < 15 ? 'warning' : 'critical'),
    };
  }

  /// Measure execution time of an asynchronous function
  Future<T> measure<T>(String label, Future<T> Function() action) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await action();
      stopwatch.stop();
      final elapsed = stopwatch.elapsedMilliseconds;
      
      if (elapsed > 100) {
        AppLogger.warning('Slow operation: $label took ${elapsed}ms');
      } else {
        AppLogger.debug('$label took ${elapsed}ms');
      }
      
      return result;
    } catch (e) {
      stopwatch.stop();
      rethrow;
    }
  }
}
