import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Premium right edge navigator strip
/// Features:
/// - Alphabet letters for quick jumping to pack names
/// - Visual indicator of current position
/// - Haptic feedback on selection
/// - Smooth glow effects
class EdgeNavigatorStrip extends StatefulWidget {
  final List<String> packNames;
  final Function(int) onLetterSelected;
  final int currentIndex;
  final bool isActive;

  const EdgeNavigatorStrip({
    super.key,
    required this.packNames,
    required this.onLetterSelected,
    required this.currentIndex,
    this.isActive = true,
  });

  @override
  State<EdgeNavigatorStrip> createState() => _EdgeNavigatorStripState();
}

class _EdgeNavigatorStripState extends State<EdgeNavigatorStrip> {
  String? _hoveredLetter;
  bool _isDragging = false;
  
  List<String> get _letters {
    final uniqueLetters = <String>{};
    for (final name in widget.packNames) {
      if (name.isNotEmpty) {
        uniqueLetters.add(name[0].toUpperCase());
      }
    }
    final sorted = uniqueLetters.toList()..sort();
    return sorted;
  }

  String get _currentLetter {
    if (widget.currentIndex < 0 || widget.currentIndex >= widget.packNames.length) {
      return '';
    }
    final name = widget.packNames[widget.currentIndex];
    return name.isNotEmpty ? name[0].toUpperCase() : '';
  }

  void _onDragUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (!widget.isActive || _letters.isEmpty) return;
    
    setState(() => _isDragging = true);
    
    final letters = _letters;
    final letterHeight = constraints.maxHeight / letters.length;
    final index = (details.localPosition.dy / letterHeight).floor().clamp(0, letters.length - 1);
    final letter = letters[index];
    
    if (_hoveredLetter != letter) {
      HapticFeedback.selectionClick();
      setState(() => _hoveredLetter = letter);
      
      final packIndex = widget.packNames.indexWhere(
        (name) => name.isNotEmpty && name[0].toUpperCase() == letter,
      );
      if (packIndex != -1) {
        widget.onLetterSelected(packIndex);
      }
    }
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _hoveredLetter = null;
    });
  }

  void _onTapLetter(String letter) {
    if (!widget.isActive) return;
    
    HapticFeedback.mediumImpact();
    
    final packIndex = widget.packNames.indexWhere(
      (name) => name.isNotEmpty && name[0].toUpperCase() == letter,
    );
    if (packIndex != -1) {
      widget.onLetterSelected(packIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_letters.isEmpty) return const SizedBox.shrink();
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return Positioned(
      right: 0,
      top: 0,
      bottom: 100,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onVerticalDragUpdate: (details) => _onDragUpdate(details, constraints),
            onVerticalDragEnd: _onDragEnd,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _isDragging ? 28 : 20,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: _isDragging
                      ? [
                          primaryColor.withOpacity(0.05),
                          primaryColor.withOpacity(0.15),
                        ]
                      : [
                          Colors.transparent,
                          isDark 
                              ? Colors.grey[900]!.withOpacity(0.5)
                              : Colors.grey[100]!.withOpacity(0.7),
                        ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _letters.map((letter) {
                  final isCurrentLetter = letter == _currentLetter;
                  final isHovered = letter == _hoveredLetter;
                  
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _onTapLetter(letter),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: EdgeInsets.all(isHovered ? 4 : 2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isHovered
                                ? primaryColor
                                : isCurrentLetter
                                    ? primaryColor.withOpacity(0.2)
                                    : Colors.transparent,
                            boxShadow: isHovered
                                ? [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.4),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            letter,
                            style: TextStyle(
                              fontSize: isHovered ? 11 : 9,
                              fontWeight: isCurrentLetter || isHovered 
                                  ? FontWeight.w700 
                                  : FontWeight.w500,
                              color: isHovered
                                  ? Colors.white
                                  : isCurrentLetter
                                      ? primaryColor
                                      : Colors.grey[500],
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideX(
      begin: 0.5,
      end: 0,
      delay: 300.ms,
      duration: 400.ms,
      curve: Curves.easeOutCubic,
    );
  }
}
