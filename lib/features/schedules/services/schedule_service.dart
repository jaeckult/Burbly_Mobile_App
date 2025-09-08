import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../models/calendar_event.dart';

class ScheduleService {
  final DataService _dataService = DataService();

  Future<List<CalendarEvent>> getCalendarEvents() async {
    try {
      // Load all decks
      final decks = await _dataService.getDecks();
      
      // Convert decks to calendar events
      return _convertDecksToEvents(decks);
    } catch (e) {
      print('Error loading calendar data: $e');
      return [];
    }
  }

  List<CalendarEvent> _convertDecksToEvents(List<Deck> decks) {
    final List<CalendarEvent> events = [];
    final now = DateTime.now();
    
    // Only add deck-level scheduled review events
    for (final deck in decks) {
      if (deck.scheduledReviewEnabled == true && deck.scheduledReviewTime != null) {
        final scheduledDate = deck.scheduledReviewTime!;
        final isOverdue = scheduledDate.isBefore(now);
        
        events.add(CalendarEvent(
          date: scheduledDate,
          title: 'Deck Review: ${deck.name}',
          color: isOverdue ? Colors.red : Colors.indigo,
          deckName: deck.name,
          isOverdue: isOverdue,
          deckId: deck.id,
        ));
      }
    }
    
    return events;
  }
}
