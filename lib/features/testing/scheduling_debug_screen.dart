import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/core.dart';

/// Debug screen for investigating deck scheduling issues
/// Shows detailed state, logs, and allows testing schedule flows
class SchedulingDebugScreen extends StatefulWidget {
  const SchedulingDebugScreen({super.key});

  @override
  State<SchedulingDebugScreen> createState() => _SchedulingDebugScreenState();
}

class _SchedulingDebugScreenState extends State<SchedulingDebugScreen> {
  final DataService _dataService = DataService();
  final OverdueService _overdueService = OverdueService();
  
  List<Deck> _allDecks = [];
  Deck? _selectedDeck;
  final List<String> _debugLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDecks();
  }

  Future<void> _loadDecks() async {
    _log('🔄 Loading all decks...');
    setState(() => _isLoading = true);
    
    try {
      final decks = await _dataService.getDecks();
      setState(() {
        _allDecks = decks;
        _isLoading = false;
      });
      _log('✅ Loaded ${decks.length} decks');
    } catch (e) {
      _log('❌ Error loading decks: $e');
      setState(() => _isLoading = false);
    }
  }

  void _log(String message) {
    final timestamp = DateFormat('HH:mm:ss.SSS').format(DateTime.now());
    setState(() {
      _debugLogs.insert(0, '[$timestamp] $message');
      if (_debugLogs.length > 100) _debugLogs.removeLast();
    });
    print('[$timestamp] SCHEDULING_DEBUG: $message');
  }

  void _selectDeck(Deck deck) {
    setState(() => _selectedDeck = deck);
    _log('📦 Selected deck: ${deck.name} (ID: ${deck.id})');
    _logDeckState(deck);
  }

  void _logDeckState(Deck deck) {
    _log('━━━ DECK STATE ━━━');
    _log('Name: ${deck.name}');
    _log('Spaced Repetition: ${deck.spacedRepetitionEnabled}');
    _log('Scheduled Review Enabled: ${deck.scheduledReviewEnabled}');
    _log('Scheduled Review Time: ${deck.scheduledReviewTime}');
    _log('Is Overdue: ${deck.deckIsOverdue}');
    _log('Is Review Now: ${deck.deckIsReviewNow}');
    _log('Is Reviewed: ${deck.deckIsReviewed}');
    _log('Overdue Start: ${deck.deckOverdueStartTime}');
    _log('Review Now Start: ${deck.deckReviewNowStartTime}');
    _log('Reviewed Start: ${deck.deckReviewedStartTime}');
    _log('━━━━━━━━━━━━━━━');
  }

  Future<void> _testScheduleNow() async {
    if (_selectedDeck == null) {
      _log('⚠️ No deck selected');
      return;
    }

    _log('🧪 TEST: Scheduling deck for 2 minutes from now');
    
    final scheduleTime = DateTime.now().add(const Duration(minutes: 2));
    _log('Target time: ${_formatDateTime(scheduleTime)}');

    try {
      final updated = _selectedDeck!.copyWith(
        scheduledReviewTime: scheduleTime,
        scheduledReviewEnabled: true,
      );

      _log('📝 Saving to database...');
      await _dataService.updateDeck(updated);
      
      _log('🔄 Reloading deck from database...');
      final reloaded = await _dataService.getDeck(_selectedDeck!.id);
      
      if (reloaded != null) {
        setState(() => _selectedDeck = reloaded);
        _log('✅ Deck reloaded successfully');
        _logDeckState(reloaded);
        
        if (reloaded.scheduledReviewTime != null) {
          _log('✅ Schedule saved! Shows: ${_formatDateTime(reloaded.scheduledReviewTime!)}');
        } else {
          _log('❌ PROBLEM: scheduledReviewTime is NULL after reload!');
        }
      }

      await _loadDecks();
    } catch (e) {
      _log('❌ Error: $e');
    }
  }

  Future<void> _testClearSchedule() async {
    if (_selectedDeck == null) return;

    _log('🧪 TEST: Clearing schedule');
    
    try {
      final updated = _selectedDeck!.copyWith(
        scheduledReviewTime: null,
        scheduledReviewEnabled: false,
      );

      await _dataService.updateDeck(updated);
      final reloaded = await _dataService.getDeck(_selectedDeck!.id);
      
      if (reloaded != null) {
        setState(() => _selectedDeck = reloaded);
        _logDeckState(reloaded);
      }

      await _loadDecks();
    } catch (e) {
      _log('❌ Error: $e');
    }
  }

  Future<void> _testUpdateTags() async {
    if (_selectedDeck == null) return;

    _log('🧪 TEST: Updating tags immediately');
    
    try {
      await _overdueService.updateDeckTagsImmediately(_selectedDeck!.id);
      
      final reloaded = await _dataService.getDeck(_selectedDeck!.id);
      if (reloaded != null) {
        setState(() => _selectedDeck = reloaded);
        _log('✅ Tags updated');
        _logDeckState(reloaded);
      }

      await _loadDecks();
    } catch (e) {
      _log('❌ Error: $e');
    }
  }

  String _formatDateTime(DateTime dt) {
    return DateFormat('MMM dd, HH:mm:ss').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheduling Debug'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Deck Selector
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Deck:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<Deck>(
                        isExpanded: true,
                        value: _selectedDeck,
                        hint: const Text('Choose a deck to debug'),
                        items: _allDecks.map((deck) {
                          return DropdownMenuItem(
                            value: deck,
                            child: Text(deck.name),
                          );
                        }).toList(),
                        onChanged: (deck) {
                          if (deck != null) _selectDeck(deck);
                        },
                      ),
                    ],
                  ),
                ),

                // Selected Deck Info
                if (_selectedDeck != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.blue[50],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedDeck!.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow('SR Enabled', '${_selectedDeck!.spacedRepetitionEnabled}'),
                        _buildInfoRow('Schedule Enabled', '${_selectedDeck!.scheduledReviewEnabled}'),
                        _buildInfoRow(
                          'Scheduled Time',
                          _selectedDeck!.scheduledReviewTime != null
                              ? _formatDateTime(_selectedDeck!.scheduledReviewTime!)
                              : 'NOT SET',
                        ),
                        _buildInfoRow('Overdue', '${_selectedDeck!.deckIsOverdue}'),
                        _buildInfoRow('Review Now', '${_selectedDeck!.deckIsReviewNow}'),
                        _buildInfoRow('Reviewed', '${_selectedDeck!.deckIsReviewed}'),
                      ],
                    ),
                  ),

                  // Test Actions
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _testScheduleNow,
                          icon: const Icon(Icons.schedule),
                          label: const Text('Schedule for 2 min from now'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _testClearSchedule,
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear Schedule'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            backgroundColor: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _testUpdateTags,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Update Tags Immediately'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            backgroundColor: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _loadDecks,
                          icon: const Icon(Icons.sync),
                          label: const Text('Reload All Decks'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            backgroundColor: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Debug Logs
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Debug Logs (with timestamps):',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _debugLogs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            _debugLogs[index],
                            style: TextStyle(
                              color: _getLogColor(_debugLogs[index]),
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(
              color: value.contains('NOT') || value.contains('false')
                  ? Colors.grey
                  : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getLogColor(String log) {
    if (log.contains('✅')) return Colors.green;
    if (log.contains('❌')) return Colors.red;
    if (log.contains('⚠️')) return Colors.orange;
    if (log.contains('🧪')) return Colors.cyan;
    if (log.contains('📦')) return Colors.yellow;
    return Colors.white;
  }
}
