import 'package:flutter/material.dart';

/// Model for a feature highlight in the walkthrough
class FeatureHighlightModel {
  /// Global key for the target widget
  final GlobalKey targetKey;
  
  /// Feature title
  final String title;
  
  /// Short friendly description (one sentence)
  final String description;
  
  /// Optional icon to show in tooltip
  final IconData? icon;

  const FeatureHighlightModel({
    required this.targetKey,
    required this.title,
    required this.description,
    this.icon,
  });
}
