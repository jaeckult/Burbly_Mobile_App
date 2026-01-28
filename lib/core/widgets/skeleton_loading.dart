import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// A collection of skeleton loading widgets for use throughout the app.
/// These replace CircularProgressIndicator for a more polished loading experience.

/// Base shimmer widget that provides consistent shimmer effect.
class ShimmerBase extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerBase({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: baseColor ?? (isDark ? Colors.grey[800]! : Colors.grey[300]!),
      highlightColor: highlightColor ?? (isDark ? Colors.grey[700]! : Colors.grey[100]!),
      child: child,
    );
  }
}

/// Skeleton placeholder box for text, images, etc.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = AppDimensions.radiusMd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Skeleton for a single deck card
class DeckCardSkeleton extends StatelessWidget {
  const DeckCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerBase(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const SkeletonBox(
                width: double.infinity,
                height: 20,
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              // Description
              const SkeletonBox(
                width: 120,
                height: 14,
              ),
              const Spacer(),
              // Pack badge
              const SkeletonBox(
                width: 80,
                height: 24,
                borderRadius: AppDimensions.radiusCircular,
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              // Card count and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  SkeletonBox(width: 60, height: 12),
                  SkeletonBox(width: 50, height: 12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton for a grid of deck cards
class DeckGridSkeleton extends StatelessWidget {
  final int itemCount;

  const DeckGridSkeleton({
    super.key,
    this.itemCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: AppDimensions.gridCrossAxisCount,
        crossAxisSpacing: AppDimensions.gridCrossAxisSpacing,
        mainAxisSpacing: AppDimensions.gridMainAxisSpacing,
        childAspectRatio: AppDimensions.gridChildAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const DeckCardSkeleton(),
    );
  }
}

/// Skeleton for a deck pack card with expandable content
class DeckPackCardSkeleton extends StatelessWidget {
  const DeckPackCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerBase(
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingLg,
          vertical: AppDimensions.spacingSm,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon placeholder
                  const SkeletonBox(
                    width: 48,
                    height: 48,
                    borderRadius: AppDimensions.radiusMd,
                  ),
                  const SizedBox(width: AppDimensions.spacingMd),
                  // Title and count
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SkeletonBox(width: 160, height: 18),
                        SizedBox(height: AppDimensions.spacingXs),
                        SkeletonBox(width: 80, height: 14),
                      ],
                    ),
                  ),
                  // Expand icon
                  const SkeletonBox(
                    width: 24,
                    height: 24,
                    borderRadius: AppDimensions.radiusCircular,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton for a list of deck pack cards
class DeckPackListSkeleton extends StatelessWidget {
  final int itemCount;

  const DeckPackListSkeleton({
    super.key,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => const DeckPackCardSkeleton(),
    );
  }
}

/// Skeleton for a flashcard item in a list
class FlashcardListItemSkeleton extends StatelessWidget {
  const FlashcardListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerBase(
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingLg,
          vertical: AppDimensions.spacingSm,
        ),
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SkeletonBox(width: double.infinity, height: 16),
            SizedBox(height: AppDimensions.spacingSm),
            SkeletonBox(width: 200, height: 14),
            SizedBox(height: AppDimensions.spacingMd),
            Row(
              children: [
                SkeletonBox(width: 60, height: 24, borderRadius: AppDimensions.radiusCircular),
                SizedBox(width: AppDimensions.spacingSm),
                SkeletonBox(width: 60, height: 24, borderRadius: AppDimensions.radiusCircular),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for a list of flashcard items
class FlashcardListSkeleton extends StatelessWidget {
  final int itemCount;

  const FlashcardListSkeleton({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => const FlashcardListItemSkeleton(),
    );
  }
}

/// Skeleton for stats cards
class StatsCardSkeleton extends StatelessWidget {
  const StatsCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerBase(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        child: Column(
          children: const [
            SkeletonBox(width: 32, height: 32, borderRadius: AppDimensions.radiusCircular),
            SizedBox(height: AppDimensions.spacingSm),
            SkeletonBox(width: 40, height: 24),
            SizedBox(height: AppDimensions.spacingXs),
            SkeletonBox(width: 60, height: 12),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for deck detail header
class DeckDetailHeaderSkeleton extends StatelessWidget {
  const DeckDetailHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerBase(
      child: Container(
        margin: const EdgeInsets.all(AppDimensions.spacingLg),
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 200, height: 24),
                      SizedBox(height: AppDimensions.spacingSm),
                      SkeletonBox(width: 140, height: 14),
                    ],
                  ),
                ),
                const SkeletonBox(
                  width: 80,
                  height: 36,
                  borderRadius: AppDimensions.radiusLg,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingXl),
            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(4, (_) => const StatsCardSkeleton()),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for notification list item
class NotificationItemSkeleton extends StatelessWidget {
  const NotificationItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerBase(
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingLg,
          vertical: AppDimensions.spacingSm,
        ),
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Row(
          children: [
            const SkeletonBox(
              width: 40,
              height: 40,
              borderRadius: AppDimensions.radiusCircular,
            ),
            const SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: double.infinity, height: 16),
                  SizedBox(height: AppDimensions.spacingXs),
                  SkeletonBox(width: 180, height: 12),
                ],
              ),
            ),
            const SkeletonBox(width: 60, height: 12),
          ],
        ),
      ),
    );
  }
}

/// Generic full-page skeleton with customizable content
class FullPageSkeleton extends StatelessWidget {
  final Widget child;

  const FullPageSkeleton({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: child),
    );
  }
}

/// Loading overlay with shimmer effect
class LoadingOverlay extends StatelessWidget {
  final String? message;

  const LoadingOverlay({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.spacingXl),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (message != null) ...[
                const SizedBox(height: AppDimensions.spacingLg),
                Text(message!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
