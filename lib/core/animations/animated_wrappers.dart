import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'motion_config.dart';

/// Reusable animated wrapper widgets.
/// Drop these around any widget to add polish without touching business logic.

// ============ ENTRANCE ANIMATIONS ============

/// Fades in and scales up from slightly smaller.
/// Great for cards, dialogs, and content appearing on screen.
class FadeInScale extends StatelessWidget {
  final Widget child;
  final Duration? delay;
  final Duration? duration;
  final double? beginScale;

  const FadeInScale({
    super.key,
    required this.child,
    this.delay,
    this.duration,
    this.beginScale,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay ?? Duration.zero)
        .fadeIn(duration: duration ?? AppMotion.durationMd, curve: AppMotion.curveStandard)
        .scale(
          begin: Offset(beginScale ?? AppMotion.scaleEntranceStart, beginScale ?? AppMotion.scaleEntranceStart),
          end: const Offset(1, 1),
          duration: duration ?? AppMotion.durationMd,
          curve: AppMotion.curveEmphasizedDecelerate,
        );
  }
}

/// Fades in while sliding up from below.
/// Great for bottom sheets, toasts, and list items.
class FadeInSlideUp extends StatelessWidget {
  final Widget child;
  final Duration? delay;
  final Duration? duration;

  const FadeInSlideUp({
    super.key,
    required this.child,
    this.delay,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay ?? Duration.zero)
        .fadeIn(duration: duration ?? AppMotion.durationMd, curve: AppMotion.curveFade)
        .slideY(
          begin: 0.1,
          end: 0,
          duration: duration ?? AppMotion.durationMd,
          curve: AppMotion.curveEmphasizedDecelerate,
        );
  }
}

/// Configurable entrance animation with multiple options.
class AnimateIn extends StatelessWidget {
  final Widget child;
  final Duration? delay;
  final Duration? duration;
  final bool fade;
  final bool scale;
  final bool slideUp;
  final bool slideRight;

  const AnimateIn({
    super.key,
    required this.child,
    this.delay,
    this.duration,
    this.fade = true,
    this.scale = false,
    this.slideUp = false,
    this.slideRight = false,
  });

  @override
  Widget build(BuildContext context) {
    var animated = child.animate(delay: delay ?? Duration.zero);
    final dur = duration ?? AppMotion.durationMd;
    
    if (fade) {
      animated = animated.fadeIn(duration: dur, curve: AppMotion.curveFade);
    }
    if (scale) {
      animated = animated.scale(
        begin: const Offset(0.95, 0.95),
        end: const Offset(1, 1),
        duration: dur,
        curve: AppMotion.curveEmphasizedDecelerate,
      );
    }
    if (slideUp) {
      animated = animated.slideY(begin: 0.1, end: 0, duration: dur, curve: AppMotion.curveStandard);
    }
    if (slideRight) {
      animated = animated.slideX(begin: -0.1, end: 0, duration: dur, curve: AppMotion.curveStandard);
    }
    
    return animated;
  }
}

// ============ STAGGERED LIST ANIMATION ============

/// Wraps a list of children with staggered entrance animations.
/// Each child fades in with a slight delay after the previous.
class StaggeredFadeList extends StatelessWidget {
  final List<Widget> children;
  final Axis direction;
  final Duration? staggerDelay;
  final Duration? itemDuration;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  const StaggeredFadeList({
    super.key,
    required this.children,
    this.direction = Axis.vertical,
    this.staggerDelay,
    this.itemDuration,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
  });

  @override
  Widget build(BuildContext context) {
    final stagger = staggerDelay ?? AppMotion.staggerDelay;
    final dur = itemDuration ?? AppMotion.durationMd;

    final animatedChildren = children.asMap().entries.map((entry) {
      final index = entry.key;
      final child = entry.value;
      // Cap stagger to prevent long waits
      final effectiveIndex = index.clamp(0, AppMotion.maxStaggerItems);
      
      return child
          .animate(delay: stagger * effectiveIndex)
          .fadeIn(duration: dur, curve: AppMotion.curveFade)
          .slideY(
            begin: 0.05,
            end: 0,
            duration: dur,
            curve: AppMotion.curveEmphasizedDecelerate,
          );
    }).toList();

    if (direction == Axis.vertical) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: animatedChildren,
      );
    } else {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: animatedChildren,
      );
    }
  }
}

/// For ListView.builder - wraps individual items with stagger
class StaggeredListItem extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration? staggerDelay;
  final Duration? duration;

  const StaggeredListItem({
    super.key,
    required this.child,
    required this.index,
    this.staggerDelay,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final stagger = staggerDelay ?? AppMotion.staggerDelay;
    final dur = duration ?? AppMotion.durationMd;
    final effectiveIndex = index.clamp(0, AppMotion.maxStaggerItems);

    return child
        .animate(delay: stagger * effectiveIndex)
        .fadeIn(duration: dur, curve: AppMotion.curveFade)
        .slideY(
          begin: 0.03,
          end: 0,
          duration: dur,
          curve: AppMotion.curveEmphasizedDecelerate,
        );
  }
}

// ============ MICRO-INTERACTIONS ============

/// Provides subtle scale-down feedback on press.
/// Wrap interactive elements (buttons, cards) for tactile feel.
class PressFeedback extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleFactor;

  const PressFeedback({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleFactor = 0.97,
  });

  @override
  State<PressFeedback> createState() => _PressFeedbackState();
}

class _PressFeedbackState extends State<PressFeedback> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleFactor : 1.0,
        duration: AppMotion.durationXs,
        curve: AppMotion.curveStandard,
        child: widget.child,
      ),
    );
  }
}

/// Animated visibility toggle with fade
class AnimatedVisibility extends StatelessWidget {
  final Widget child;
  final bool visible;
  final Duration? duration;

  const AnimatedVisibility({
    super.key,
    required this.child,
    required this.visible,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: duration ?? AppMotion.durationSm,
      curve: AppMotion.curveFade,
      child: IgnorePointer(
        ignoring: !visible,
        child: child,
      ),
    );
  }
}

/// Shimmer loading effect wrapper
class ShimmerEffect extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.isLoading = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;
    
    return child
        .animate(onComplete: (controller) => controller.repeat())
        .shimmer(
          duration: const Duration(milliseconds: 1500),
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.1)
              : Colors.white.withOpacity(0.5),
        );
  }
}

// ============ MICRO-SMOOTHING WIDGETS ============

/// Smooth transition between different child widgets.
/// Use this to replace abrupt content swaps with smooth crossfades.
/// 
/// Example:
/// ```dart
/// SmoothStateTransition(
///   child: isLoading ? LoadingWidget() : ContentWidget(),
/// )
/// ```
class SmoothStateTransition extends StatelessWidget {
  final Widget child;
  final Duration? duration;
  final Curve? switchInCurve;
  final Curve? switchOutCurve;

  const SmoothStateTransition({
    super.key,
    required this.child,
    this.duration,
    this.switchInCurve,
    this.switchOutCurve,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration ?? AppMotion.durationSm,
      switchInCurve: switchInCurve ?? AppMotion.curveStandard,
      switchOutCurve: switchOutCurve ?? AppMotion.curveEmphasizedAccelerate,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: AppMotion.curveEmphasizedDecelerate,
              ),
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Smooth transition from loading state to content.
/// Provides consistent loading→content experience across screens.
/// 
/// Example:
/// ```dart
/// SmoothLoadingTransition(
///   isLoading: state.isLoading,
///   loadingWidget: DeckPackListSkeleton(),
///   child: DeckPackList(...),
/// )
/// ```
class SmoothLoadingTransition extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Widget? loadingWidget;
  final Duration? duration;

  const SmoothLoadingTransition({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingWidget,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration ?? AppMotion.durationMd,
      switchInCurve: AppMotion.curveEmphasizedDecelerate,
      switchOutCurve: AppMotion.curveEmphasizedAccelerate,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: isLoading
          ? KeyedSubtree(
              key: const ValueKey('loading'),
              child: loadingWidget ?? const Center(child: CircularProgressIndicator()),
            )
          : KeyedSubtree(
              key: const ValueKey('content'),
              child: child,
            ),
    );
  }
}

/// Smooth size changes for expanding/collapsing content.
/// Optimized preset for AnimatedSize with snappy timing.
/// 
/// Example:
/// ```dart
/// SmoothSizeChange(
///   child: isExpanded ? ExpandedContent() : CollapsedContent(),
/// )
/// ```
class SmoothSizeChange extends StatelessWidget {
  final Widget child;
  final Duration? duration;
  final Alignment alignment;
  final Curve? curve;

  const SmoothSizeChange({
    super.key,
    required this.child,
    this.duration,
    this.alignment = Alignment.topCenter,
    this.curve,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: duration ?? AppMotion.durationSm,
      curve: curve ?? AppMotion.curveStandard,
      alignment: alignment,
      child: child,
    );
  }
}

/// Smooth opacity change with optional size animation.
/// Use for showing/hiding content smoothly.
class SmoothReveal extends StatelessWidget {
  final Widget child;
  final bool visible;
  final Duration? duration;
  final bool animateSize;

  const SmoothReveal({
    super.key,
    required this.child,
    required this.visible,
    this.duration,
    this.animateSize = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: duration ?? AppMotion.durationSm,
      curve: AppMotion.curveFade,
      child: IgnorePointer(
        ignoring: !visible,
        child: child,
      ),
    );

    if (animateSize) {
      content = AnimatedSize(
        duration: duration ?? AppMotion.durationSm,
        curve: AppMotion.curveStandard,
        child: visible ? content : const SizedBox.shrink(),
      );
    }

    return content;
  }
}
