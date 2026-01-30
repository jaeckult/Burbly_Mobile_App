import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Premium Burbly AI Panel - Interactive assistant panel
/// Replaces vertical edge strip with tap-to-expand AI features
class BurblyAIPanel extends StatefulWidget {
  final ValueNotifier<bool> isExpandedNotifier;
  
  const BurblyAIPanel({
    super.key,
    required this.isExpandedNotifier,
  });

  @override
  State<BurblyAIPanel> createState() => _BurblyAIPanelState();
}

class _BurblyAIPanelState extends State<BurblyAIPanel> 
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _togglePanel() {
    HapticFeedback.mediumImpact();
    widget.isExpandedNotifier.value = !widget.isExpandedNotifier.value;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final expandedWidth = screenWidth - 65; // Fill space next to 50px strip

    return ValueListenableBuilder<bool>(
      valueListenable: widget.isExpandedNotifier,
      builder: (context, isExpanded, child) {
        return AnimatedPositioned(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutQuart,
          right: 0,
          top: 140, // Unwired top animation (keeps header visible)
          bottom: isExpanded ? 0 : 100,
          width: isExpanded ? expandedWidth : 28,
          child: Material(
            elevation: isExpanded ? 16 : 4,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isExpanded ? 30 : 14), // More rounded when expanded
              bottomLeft: Radius.circular(isExpanded ? 30 : 14),
            ),
            color: Colors.transparent,
            child: GestureDetector(
              onTap: isExpanded ? null : _togglePanel, // Tap to open if closed
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutQuart,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isExpanded
                        ? [
                            const Color(0xFF667eea),
                            const Color(0xFF764ba2),
                            const Color(0xFF5851DB),
                          ]
                        : [
                            const Color(0xFF667eea),
                            const Color(0xFF8B5CF6),
                          ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isExpanded ? 30 : 14),
                    bottomLeft: Radius.circular(isExpanded ? 30 : 14),
                  ),
                ),
                child: ClipRect(
                  child: OverflowBox(
                    maxWidth: expandedWidth,
                    minWidth: expandedWidth,
                    alignment: Alignment.centerRight,
                    child: AnimatedCrossFade(
                      firstChild: _buildCollapsedStrip(expandedWidth),
                      secondChild: SizedBox(
                        width: expandedWidth,
                        height: MediaQuery.of(context).size.height,
                        child: Column(
                          children: [
                            _buildHeader(),
                            Expanded(child: _buildContent()),
                            _buildFooter(),
                          ],
                        ),
                      ),
                      crossFadeState: isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 400),
                      firstCurve: Curves.easeOut,
                      secondCurve: Curves.easeIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCollapsedStrip(double expandedWidth) {
    return SizedBox(
      width: expandedWidth, // Full width to align content to right edge
      child: Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: 28,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Icon(
                    Icons.auto_awesome,
                    color: Color.lerp(
                      const Color(0xFFFBBF24),
                      Colors.white,
                      _pulseController.value,
                    ),
                    size: 20,
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildDotIndicator(size: 4),
              const SizedBox(height: 4),
              _buildDotIndicator(size: 6, highlighted: true),
              const SizedBox(height: 4),
              _buildDotIndicator(size: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDotIndicator({required double size, bool highlighted = false}) {
    return Container(
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


  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 44, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome, color: Color(0xFFFBBF24), size: 14),
              ),
              const SizedBox(width: 10),
              Text(
                'Burbly AI',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 20),
            onPressed: _togglePanel,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Scaled 24, 10 -> 16, 8
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildGreetingSection(),
          const SizedBox(height: 24), // Scaled 32 -> 24
          _buildMagicInputSection(),
          const SizedBox(height: 24),
          Text(
            'QUICK CREATION',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 8, // Scaled 10 -> 8
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12), // Scaled 16 -> 12
          Row(
            children: [
              Expanded(
                child: _buildLargeActionCard(
                  icon: Icons.add_rounded,
                  title: 'New Deck',
                  subtitle: 'Manual Entry',
                  color: const Color(0xFF60A5FA),
                  onTap: () => _showDummyDialog('Starting manual deck creation...'),
                ),
              ),
              const SizedBox(width: 8), // Scaled 12 -> 8
              Expanded(
                child: _buildLargeActionCard(
                  icon: Icons.bolt_rounded,
                  title: 'AI Generate',
                  subtitle: 'From Topic',
                  color: const Color(0xFFFBBF24),
                  onTap: _showGenerateDialog,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // Scaled 12 -> 8
          _buildLargeActionCard(
            icon: Icons.mic_rounded,
            title: 'Voice Note to Deck',
            subtitle: 'Speak and let AI organize it',
            color: const Color(0xFFF472B6),
            isHorizontal: true,
            onTap: () => _showDummyDialog('Listening...'),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'Hello,',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16, // Scaled 24 -> 16
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Yitbarek',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16, // Scaled 24 -> 16
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'What would you like to learn or create today?',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 10, // Scaled 14 -> 10
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildMagicInputSection() {
    return GestureDetector(
      onTap: _showMagicInputModal,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: AbsorbPointer(
          child: TextField(
            readOnly: true,
            style: const TextStyle(color: Colors.black87, fontSize: 10),
            decoration: InputDecoration(
              hintText: 'Type a topic, e.g. "French Basics"...',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 9,
              ),
              prefixIcon: Icon(Icons.auto_awesome, color: const Color(0xFF667eea).withOpacity(0.8), size: 14),
              suffixIcon: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_upward, color: Colors.white, size: 12),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLargeActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isHorizontal = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12), // Scaled 16 -> 12
        child: Container(
          padding: const EdgeInsets.all(12), // Scaled 16 -> 12
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: isHorizontal
              ? Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8), // Scaled 10 -> 8
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 14), // Scaled 20 -> 14
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10, // Scaled 14 -> 10
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 8, // Scaled 10 -> 8
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 16), // Scaled 24 -> 16
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10, // Scaled 14 -> 10
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 8, // Scaled 10 -> 8
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(16), // Scaled 24 -> 16
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome,
                color: Colors.white.withOpacity(0.3 + (_pulseController.value * 0.2)),
                size: 10, // Scaled 12 -> 10
              ),
              const SizedBox(width: 6),
              Text(
                'Personal Assistant Active',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 8, // Scaled 10 -> 8
                  letterSpacing: 0.5,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDummyDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
    
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This is a demo feature - AI integration coming soon!'),
            backgroundColor: Color(0xFF8B5CF6),
          ),
        );
      }
    });
  }

  void _showMagicInputModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFF5851DB), size: 18),
                const SizedBox(width: 8),
                Text(
                  'Ask Burbly',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              autofocus: true,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'What do you want to learn?',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (value) {
                Navigator.pop(context);
                _showDummyDialog('Processing: "$value"');
              },
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildModalChip('🇪🇸 Spanish Basics'),
                _buildModalChip('🐍 Python loops'),
                _buildModalChip('🧬 Mitosis'),
                _buildModalChip('📜 World War II dates'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalChip(String label) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: const Color(0xFFF3F4F6),
      labelStyle: const TextStyle(color: Colors.black87),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
      onPressed: () {
        Navigator.pop(context);
        _showDummyDialog('Generating flashcards for: $label');
      },
    );
  }

  void _showGenerateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFFFBBF24)),
            SizedBox(width: 8),
            Text('Generate Flashcards'),
          ],
        ),
        content: const Text(
          'Burbly AI can generate flashcards from:\n\n'
          '• Pasted text or notes\n'
          '• PDF documents\n'
          '• Web articles\n'
          '• YouTube transcripts\n\n'
          'This feature is coming soon!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}


