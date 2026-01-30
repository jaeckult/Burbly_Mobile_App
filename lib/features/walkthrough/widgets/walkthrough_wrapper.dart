import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/walkthrough_bloc.dart';
import '../bloc/walkthrough_event.dart';
import '../bloc/walkthrough_state.dart';
import '../models/feature_highlight_model.dart';
import '../../../core/services/onboarding_service.dart';

/// Wrapper widget to easily integrate walkthrough into any screen
class WalkthroughWrapper extends StatefulWidget {
  final String screenName;
  final List<FeatureHighlightModel> highlights;
  final Widget child;

  const WalkthroughWrapper({
    Key? key,
    required this.screenName,
    required this.highlights,
    required this.child,
  }) : super(key: key);

  @override
  State<WalkthroughWrapper> createState() => _WalkthroughWrapperState();
}

class _WalkthroughWrapperState extends State<WalkthroughWrapper> {
  bool _walkthroughTriggered = false;

  @override
  void initState() {
    super.initState();
    _checkAndTriggerWalkthrough();
  }

  Future<void> _checkAndTriggerWalkthrough() async {
    // Check if walkthrough should be shown
    final onboardingService = OnboardingService();
    final completed = await onboardingService.isWalkthroughCompleted(widget.screenName);
    
    if (!completed && !_walkthroughTriggered && mounted) {
      _walkthroughTriggered = true;
      
      // Wait for UI to build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.highlights.isNotEmpty) {
          // Set total highlights in bloc
          context.read<WalkthroughBloc>().setTotalHighlights(widget.highlights.length);
          
          // Start showcase
          ShowCaseWidget.of(context).startShowCase(
            widget.highlights.map((h) => h.targetKey).toList(),
          );
          
          // Update bloc state
          context.read<WalkthroughBloc>().add(StartWalkthrough(widget.screenName));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalkthroughBloc, WalkthroughState>(
      listener: (context, state) {
        if (state is WalkthroughCompleted && state.screenName == widget.screenName) {
          // Walkthrough completed, dismiss showcase
          ShowCaseWidget.of(context).dismiss();
        }
      },
      child: ShowCaseWidget(
        builder: (context) => widget.child,
        onStart: (index, key) {
          // Optional: Track which highlight is being shown
        },
        onComplete: (index, key) {
          // Move to next highlight
          context.read<WalkthroughBloc>().add(const NextHighlight());
        },
        onFinish: () {
          // All highlights shown, complete walkthrough
          context.read<WalkthroughBloc>().add(const CompleteWalkthrough());
        },
        blurValue: 2,
        disableBarrierInteraction: true,
        disableMovingAnimation: false,
      ),
    );
  }
}

/// Helper extension to easily wrap showcase around widgets
extension ShowcaseExtension on Widget {
  Widget withShowcase({
    required GlobalKey key,
    required String title,
    required String description,
    IconData? icon,
  }) {
    return Showcase(
      key: key,
      title: title,
      description: description,
      targetShapeBorder: const CircleBorder(),
      overlayOpacity: 0.7,
      overlayColor: Colors.black,
      tooltipBackgroundColor: Colors.white,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF667eea),
      ),
      descTextStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.black87,
      ),
      targetPadding: const EdgeInsets.all(12),
      disableDefaultTargetGestures: false,
      child: this,
    );
  }
}
