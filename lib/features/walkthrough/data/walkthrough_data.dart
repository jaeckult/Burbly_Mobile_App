import 'package:flutter/material.dart';
import '../models/feature_highlight_model.dart';

/// Predefined walkthrough highlights for key screens
class WalkthroughData {
  // Screen identifiers
  static const String deckPackListScreen = 'deck_pack_list';
  static const String studyScreen = 'study_screen';
  
  /// Get highlights for Deck Pack List Screen
  static List<FeatureHighlightModel> getDeckPackListHighlights({
    required GlobalKey createDeckKey,
    required GlobalKey deckCardKey,
    required GlobalKey statsKey,
  }) {
    return [
      FeatureHighlightModel(
        targetKey: createDeckKey,
        title: 'Create Your First Deck',
        description: 'Tap here to organize your flashcards into meaningful study sets.',
        icon: Icons.add_circle_outline,
      ),
      FeatureHighlightModel(
        targetKey: deckCardKey,
        title: 'Start Learning',
        description: 'Tap any deck to begin studying with spaced repetition.',
        icon: Icons.play_circle_outline,
      ),
      FeatureHighlightModel(
        targetKey: statsKey,
        title: 'Track Your Progress',
        description: 'View detailed statistics and watch your knowledge grow.',
        icon: Icons.bar_chart_rounded,
      ),
    ];
  }
  
  /// Get highlights for Study Screen
  static List<FeatureHighlightModel> getStudyHighlights({
    required GlobalKey flipCardKey,
    required GlobalKey ratingKey,
    required GlobalKey progressKey,
  }) {
    return [
      FeatureHighlightModel(
        targetKey: flipCardKey,
        title: 'Flip to Reveal',
        description: 'Tap the card to see the answer and test yourself.',
        icon: Icons.flip,
      ),
      FeatureHighlightModel(
        targetKey: ratingKey,
        title: 'Rate Your Memory',
        description: 'Choose how well you remembered to optimize learning.',
        icon: Icons.star_outline,
      ),
      FeatureHighlightModel(
        targetKey: progressKey,
        title: 'Watch Progress',
        description: 'Track remaining cards and session completion.',
        icon: Icons.trending_up,
      ),
    ];
  }
}
