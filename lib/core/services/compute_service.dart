import 'dart:async';
import 'package:flutter/foundation.dart';

/// Service for offloading heavy computations to isolates
/// This prevents UI thread blocking during expensive operations
class ComputeService {
  static final ComputeService _instance = ComputeService._internal();
  factory ComputeService() => _instance;
  ComputeService._internal();

  /// Calculate stats for a deck in a background isolate
  Future<Map<String, dynamic>> calculateDeckStats({
    required List<Map<String, dynamic>> sessions,
  }) async {
    if (sessions.isEmpty) {
      return {
        'totalSessions': 0,
        'averageScore': 0.0,
        'totalStudyTime': 0,
        'bestScore': 0.0,
        'cardsStudied': 0,
      };
    }

    return compute(_computeDeckStats, sessions);
  }

  /// Calculate overall stats in a background isolate
  Future<Map<String, dynamic>> calculateOverallStats({
    required List<Map<String, dynamic>> sessions,
    required int totalDecks,
    required int totalCards,
  }) async {
    if (sessions.isEmpty) {
      return {
        'totalSessions': 0,
        'totalDecks': totalDecks,
        'totalCards': totalCards,
        'averageScore': 0.0,
        'totalStudyTime': 0,
      };
    }

    final data = {
      'sessions': sessions,
      'totalDecks': totalDecks,
      'totalCards': totalCards,
    };

    return compute(_computeOverallStats, data);
  }

  /// Search through items in background isolate
  Future<List<Map<String, dynamic>>> searchItems({
    required List<Map<String, dynamic>> items,
    required String query,
    required List<String> searchFields,
  }) async {
    final data = {
      'items': items,
      'query': query.toLowerCase(),
      'searchFields': searchFields,
    };

    return compute(_computeSearch, data);
  }
}

// Top-level functions for isolate execution

Map<String, dynamic> _computeDeckStats(List<Map<String, dynamic>> sessions) {
  final totalSessions = sessions.length;
  final averageScore = sessions
      .map((s) => s['averageScore'] as double)
      .reduce((a, b) => a + b) / totalSessions;
  final totalStudyTime = sessions
      .map((s) => s['studyTimeSeconds'] as int)
      .reduce((a, b) => a + b);
  final bestScore = sessions
      .map((s) => s['averageScore'] as double)
      .reduce((a, b) => a > b ? a : b);
  final cardsStudied = sessions
      .map((s) => s['totalCards'] as int)
      .reduce((a, b) => a + b);

  return {
    'totalSessions': totalSessions,
    'averageScore': averageScore,
    'totalStudyTime': totalStudyTime,
    'bestScore': bestScore,
    'cardsStudied': cardsStudied,
  };
}

Map<String, dynamic> _computeOverallStats(Map<String, dynamic> data) {
  final sessions = data['sessions'] as List<Map<String, dynamic>>;
  final totalDecks = data['totalDecks'] as int;
  final totalCards = data['totalCards'] as int;

  final totalSessions = sessions.length;
  final averageScore = sessions
      .map((s) => s['averageScore'] as double)
      .reduce((a, b) => a + b) / totalSessions;
  final totalStudyTime = sessions
      .map((s) => s['studyTimeSeconds'] as int)
      .reduce((a, b) => a + b);

  return {
    'totalSessions': totalSessions,
    'totalDecks': totalDecks,
    'totalCards': totalCards,
    'averageScore': averageScore,
    'totalStudyTime': totalStudyTime,
  };
}

List<Map<String, dynamic>> _computeSearch(Map<String, dynamic> data) {
  final items = data['items'] as List<Map<String, dynamic>>;
  final query = data['query'] as String;
  final searchFields = data['searchFields'] as List<String>;

  return items.where((item) {
    for (final field in searchFields) {
      final value = item[field];
      if (value != null && value.toString().toLowerCase().contains(query)) {
        return true;
      }
    }
    return false;
  }).toList();
}
