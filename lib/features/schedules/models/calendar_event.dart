import 'package:flutter/material.dart';

class CalendarEvent {
  final DateTime date;
  final String title;
  final Color color;
  final String deckName;
  final bool isOverdue;
  final String? deckId;

  CalendarEvent({
    required this.date,
    required this.title,
    required this.color,
    required this.deckName,
    required this.isOverdue,
    this.deckId,
  });
}

