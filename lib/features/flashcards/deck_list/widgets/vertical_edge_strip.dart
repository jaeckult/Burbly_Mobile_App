import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/flow_scroll_controller.dart';

/// Premium vertical edge navigator strip with gradient styling and progress indicator
/// Features:
/// - Vibrant blue gradient
/// - Positioned on right edge
/// - Shows progress in flow mode
/// - Activates flow mode on drag
class VerticalEdgeStrip extends StatefulWidget {
  final FlowScrollController? flowScrollController;
  final VoidCallback? onDragStart;
  final Function(double)? onDragUpdate;
  
  const VerticalEdgeStrip({
    super.key,
    this.flowScrollController,
    this.onDragStart,
    this.onDragUpdate,
  });

  @override
  State<VerticalEdgeStrip> createState() => _VerticalEdgeStripState();
}

class _VerticalEdgeStripState extends State<VerticalEdgeStrip> 
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isPressed = false;
  double _dragStartY = 0;
  double _currentDragY = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    widget.flowScrollController?.addListener(_onFlowStateChanged);
  }

  @override
  void dispose() {
    widget.flowScrollController?.removeListener(_onFlowStateChanged);
    _pulseController.dispose();
    super.dispose();
  }

  void _onFlowStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFlowMode = widget.flowScrollController?.isFlowMode ?? false;
    final progress = widget.flowScrollController?.scrollProgress ?? 0.0;
    
    return Positioned(
      right: 0,
      top: 140,
      bottom: 100,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onVerticalDragStart: (details) {
          HapticFeedback.mediumImpact();
          setState(() {
            _isPressed = true;
            _dragStartY = details.localPosition.dy;
            _currentDragY = details.localPosition.dy;
          });
          widget.onDragStart?.call();
        },
        onVerticalDragUpdate: (details) {
          setState(() => _currentDragY = details.localPosition.dy);
          final delta = (details.localPosition.dy - _dragStartY) / 500.0;
          widget.onDragUpdate?.call(delta);
          _dragStartY = details.localPosition.dy;
        },
        onVerticalDragEnd: (_) {
          setState(() => _isPressed = false);
          HapticFeedback.lightImpact();
        },
        onVerticalDragCancel: () => setState(() => _isPressed = false),
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: _isPressed ? 30 : 28,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isFlowMode
    ? [
        // A soft, glowing cyan-blue
        const Color(0xFF64B5F6).withOpacity(0.8 + _pulseController.value * 0.2), 
        // A very light, almost white-blue for the "shine" in the middle
        const Color(0xFFBBDEFB), 
        const Color(0xFF64B5F6).withOpacity(0.8 + _pulseController.value * 0.2),
      ]
    : [
        // A clean, standard light blue for non-flow state
        const Color(0xFF90CAF9).withOpacity(0.7),
        const Color(0xFF64B5F6),
        const Color(0xFF90CAF9).withOpacity(0.7),
      ],
stops: const [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2196F3).withOpacity(0.3 + _pulseController.value * 0.15),
                    blurRadius: _isPressed ? 12 : 8,
                    spreadRadius: _isPressed ? 2 : 0,
                    offset: const Offset(-2, 0),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Progress indicator (fills from bottom to top)
                  if (isFlowMode)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: MediaQuery.of(context).size.height * 0.6 * progress.clamp(0.0, 1.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              const Color(0xFF0D47A1).withOpacity(0.9),
                              const Color(0xFF1565C0).withOpacity(0.7),
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  
                  // UI elements
                  Column(
                    children: [
                      // Top handle
                      const SizedBox(height: 12),
                      _buildHandle(),
                      
                      const Spacer(),
                      
                      // Center dot indicators
                      _buildDotIndicator(size: 4),
                      const SizedBox(height: 8),
                      _buildDotIndicator(size: 6, highlighted: isFlowMode),
                      const SizedBox(height: 8),
                      _buildDotIndicator(size: 4),
                      
                      const Spacer(),
                      
                      // Bottom handle
                      _buildHandle(),
                      const SizedBox(height: 12),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 4,
      height: 16,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildDotIndicator({required double size, bool highlighted = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: highlighted ? size + 2 : size,
      height: highlighted ? size + 2 : size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(highlighted ? 0.9 : 0.5),
        boxShadow: highlighted
            ? [
                BoxShadow(
                  color: Colors.white.withOpacity(0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }
}

