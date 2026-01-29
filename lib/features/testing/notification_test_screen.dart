import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/services/native_notification_service.dart';

/// Comprehensive test screen for the notification system.
/// Each test is clearly labeled and shows exactly what it does.
class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  final List<String> _testLogs = [];
  bool _canScheduleExact = false;
  bool _isInitialized = false;
  int _scheduledCount = 0;
  
  @override
  void initState() {
    super.initState();
    _initialize();
  }
  
  Future<void> _initialize() async {
    _log('🔄 Initializing Notification Test Screen...');
    
    try {
      await NativeNotificationService.initialize();
      final canSchedule = await NativeNotificationService.canScheduleExactAlarms();
      
      setState(() {
        _isInitialized = true;
        _canScheduleExact = canSchedule;
      });
      
      _log('✅ Initialized successfully');
      _log(_canScheduleExact 
        ? '✅ Exact alarms: ENABLED (precise timing)'
        : '⚠️ Exact alarms: DISABLED (will use inexact)'
      );
    } catch (e) {
      _log('❌ Initialization failed: $e');
    }
  }
  
  void _log(String message) {
    setState(() {
      _testLogs.insert(0, '[${_formatTime(DateTime.now())}] $message');
      if (_testLogs.length > 50) _testLogs.removeLast();
    });
  }
  
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
           '${time.minute.toString().padLeft(2, '0')}:'
           '${time.second.toString().padLeft(2, '0')}';
  }
  
  //═══════════════════════════════════════════════════════════════
  // TEST 1: Immediate Notification (10 seconds)
  //═══════════════════════════════════════════════════════════════
  Future<void> _testImmediate() async {
    _log('🧪 TEST 1: Immediate Notification');
    _log('⏱️ Scheduling notification for 10 seconds from now...');
    
    final scheduledTime = DateTime.now().add(const Duration(seconds: 10));
    
    final success = await NativeNotificationService.scheduleStudyReminder(
      reminderId: 1001,
      scheduledTime: scheduledTime,
      title: '🧪 TEST 1: Immediate Test',
      message: 'This notification was scheduled 10 seconds ago!',
    );
    
    if (success) {
      setState(() => _scheduledCount++);
      _log('✅ Scheduled for ${_formatTime(scheduledTime)}');
      _log('⏰ Notification will appear in 10 seconds');
      _log('📱 Watch your notification tray!');
    } else {
      _log('❌ Failed to schedule');
    }
  }
  
  //═══════════════════════════════════════════════════════════════
  // TEST 2: Flashcard Review Notification (30 seconds)
  //═══════════════════════════════════════════════════════════════
  Future<void> _testFlashcardReview() async {
    _log('🧪 TEST 2: Flashcard Review Notification');
    _log('⏱️ Scheduling for 30 seconds from now...');
    
    final scheduledTime = DateTime.now().add(const Duration(seconds: 30));
    
    final success = await NativeNotificationService.scheduleFlashcardReview(
      reminderId: 2001,
      scheduledTime: scheduledTime,
      deckName: 'Test Deck - Spanish Vocabulary',
      cardCount: 15,
      deckId: 'test_deck_spanish_vocab',
    );
    
    if (success) {
      setState(() => _scheduledCount++);
      _log('✅ Flashcard review scheduled');
      _log('📚 Deck: "Test Deck - Spanish Vocabulary"');
      _log('🎴 Cards: 15 cards due');
      _log('⏰ Will show in 30 seconds');
    } else {
      _log('❌ Failed to schedule');
    }
  }
  
  //═══════════════════════════════════════════════════════════════
  // TEST 3: Daily Goal Notification (1 minute)
  //═══════════════════════════════════════════════════════════════
  Future<void> _testDailyGoal() async {
    _log('🧪 TEST 3: Daily Goal Notification');
    _log('⏱️ Scheduling for 1 minute from now...');
    
    final scheduledTime = DateTime.now().add(const Duration(minutes: 1));
    
    final success = await NativeNotificationService.scheduleDailyGoal(
      reminderId: 3001,
      scheduledTime: scheduledTime,
      goalProgress: 'You have studied 12 cards today! Keep going! 🎯',
    );
    
    if (success) {
      setState(() => _scheduledCount++);
      _log('✅ Daily goal reminder scheduled');
      _log('🎯 Progress: 12 cards studied');
      _log('⏰ Will show in 1 minute');
    } else {
      _log('❌ Failed to schedule');
    }
  }
  
  //═══════════════════════════════════════════════════════════════
  // TEST 4: Multiple Notifications (staggered)
  //═══════════════════════════════════════════════════════════════
  Future<void> _testMultiple() async {
    _log('🧪 TEST 4: Multiple Staggered Notifications');
    _log('⏱️ Scheduling 3 notifications at different times...');
    
    final now = DateTime.now();
    
    // First at 15 seconds
    await NativeNotificationService.scheduleStudyReminder(
      reminderId: 4001,
      scheduledTime: now.add(const Duration(seconds: 15)),
      title: '🧪 TEST 4-A: First Notification',
      message: 'This is notification 1 of 3',
    );
    _log('✅ Notification 1/3 scheduled (15 seconds)');
    
    // Second at 45 seconds
    await NativeNotificationService.scheduleStudyReminder(
      reminderId: 4002,
      scheduledTime: now.add(const Duration(seconds: 45)),
      title: '🧪 TEST 4-B: Second Notification',
      message: 'This is notification 2 of 3',
    );
    _log('✅ Notification 2/3 scheduled (45 seconds)');
    
    // Third at 75 seconds
    await NativeNotificationService.scheduleStudyReminder(
      reminderId: 4003,
      scheduledTime: now.add(const Duration(seconds: 75)),
      title: '🧪 TEST 4-C: Third Notification',
      message: 'This is notification 3 of 3',
    );
    _log('✅ Notification 3/3 scheduled (75 seconds)');
    
    setState(() => _scheduledCount += 3);
    _log('📱 Watch for 3 notifications over the next 75 seconds!');
  }
  
  //═══════════════════════════════════════════════════════════════
  // TEST 5: Cancel Notification
  //═══════════════════════════════════════════════════════════════
  Future<void> _testCancel() async {
    _log('🧪 TEST 5: Cancel Notification');
    _log('⏱️ First, scheduling a notification for 20 seconds...');
    
    final scheduledTime = DateTime.now().add(const Duration(seconds: 20));
    
    await NativeNotificationService.scheduleStudyReminder(
      reminderId: 5001,
      scheduledTime: scheduledTime,
      title: '🧪 TEST 5: This Should Be Cancelled',
      message: 'If you see this, the cancel test FAILED!',
    );
    
    _log('✅ Scheduled notification #5001');
    setState(() => _scheduledCount++);
    
    // Wait 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    
    _log('🗑️ Now cancelling notification #5001...');
    
    final success = await NativeNotificationService.cancelReminder(5001);
    
    if (success) {
      setState(() => _scheduledCount--);
      _log('✅ Successfully cancelled notification #5001');
      _log('📱 You should NOT see this notification');
      _log('⏰ Wait 20 seconds to confirm...');
    } else {
      _log('❌ Failed to cancel');
    }
  }
  
  //═══════════════════════════════════════════════════════════════
  // TEST 6: App Kill Survival (2 minutes)
  //═══════════════════════════════════════════════════════════════
  Future<void> _testAppKillSurvival() async {
    _log('🧪 TEST 6: App Kill Survival Test');
    _log('⏱️ Scheduling notification for 2 minutes...');
    
    final scheduledTime = DateTime.now().add(const Duration(minutes: 2));
    
    final success = await NativeNotificationService.scheduleStudyReminder(
      reminderId: 6001,
      scheduledTime: scheduledTime,
      title: '🧪 TEST 6: App Kill Survival',
      message: 'Success! Notification survived app being killed! 🎉',
    );
    
    if (success) {
      setState(() => _scheduledCount++);
      _log('✅ Scheduled for ${_formatTime(scheduledTime)}');
      _log('📱 INSTRUCTIONS:');
      _log('1. Wait 5 seconds');
      _log('2. Force close this app (swipe away from recents)');
      _log('3. Wait 2 minutes');
      _log('4. Notification should still appear!');
      _log('⏰ Timer started - Kill the app now!');
    } else {
      _log('❌ Failed to schedule');
    }
  }
  
  //═══════════════════════════════════════════════════════════════
  // TEST 7: Reschedule All
  //═══════════════════════════════════════════════════════════════
  Future<void> _testRescheduleAll() async {
    _log('🧪 TEST 7: Reschedule All Test');
    _log('🔄 Creating multiple reminders to reschedule...');
    
    final now = DateTime.now();
    final reminders = [
      ReminderData(
        reminderId: 7001,
        notificationType: NativeNotificationService.typeStudyReminder,
        title: '🧪 TEST 7-A: Rescheduled Reminder',
        message: 'This was rescheduled!',
        scheduledTime: now.add(const Duration(seconds: 25)),
      ),
      ReminderData(
        reminderId: 7002,
        notificationType: NativeNotificationService.typeFlashcardReview,
        title: '🧪 TEST 7-B: Rescheduled Review',
        message: 'Flashcard review was rescheduled!',
        scheduledTime: now.add(const Duration(seconds: 50)),
        deckName: 'Rescheduled Deck',
        cardCount: 8,
      ),
    ];
    
    final successCount = await NativeNotificationService.rescheduleAll(reminders);
    
    setState(() => _scheduledCount += successCount);
    _log('✅ Rescheduled $successCount/${reminders.length} reminders');
    _log('⏰ Will show at 25s and 50s from now');
    _log('📱 This simulates boot reschedule behavior');
  }
  
  //═══════════════════════════════════════════════════════════════
  // TEST 8: Check Reboot Status
  //═══════════════════════════════════════════════════════════════
  Future<void> _testRebootCheck() async {
    _log('🧪 TEST 8: Reboot Status Check');
    _log('🔍 Checking if device was rebooted...');
    
    final needsReschedule = await NativeNotificationService.checkNeedsReschedule();
    
    if (needsReschedule) {
      _log('⚠️ Device was rebooted!');
      _log('🔄 Reminders need to be rescheduled');
      _log('📝 App should load reminders from database and reschedule');
    } else {
      _log('✅ No reboot detected');
      _log('📱 All scheduled reminders should still be active');
    }
  }
  
  //═══════════════════════════════════════════════════════════════
  // Clear All Tests
  //═══════════════════════════════════════════════════════════════
  Future<void> _clearAllTests() async {
    _log('🗑️ Clearing all test notifications...');
    
    for (int i = 1001; i <= 7002; i += 1000) {
      for (int j = 0; j < 10; j++) {
        await NativeNotificationService.cancelReminder(i + j);
      }
    }
    
    setState(() => _scheduledCount = 0);
    _log('✅ All test notifications cleared');
  }
  
  void _clearLogs() {
    setState(() => _testLogs.clear());
    _log('🧹 Logs cleared');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification System Tests'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearLogs,
            tooltip: 'Clear Logs',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Card
          _buildStatusCard(),
          
          // Test Buttons
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'QUICK TESTS (Short Wait)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 8),
                
                _buildTestButton(
                  'TEST 1: Immediate (10s)',
                  'Schedule notification for 10 seconds from now',
                  Icons.flash_on,
                  Colors.green,
                  _testImmediate,
                ),
                
                _buildTestButton(
                  'TEST 2: Flashcard Review (30s)',
                  'Test flashcard review notification with deck info',
                  Icons.style,
                  Colors.blue,
                  _testFlashcardReview,
                ),
                
                _buildTestButton(
                  'TEST 3: Daily Goal (1m)',
                  'Test daily goal reminder notification',
                  Icons.flag,
                  Colors.orange,
                  _testDailyGoal,
                ),
                
                _buildTestButton(
                  'TEST 4: Multiple Staggered (15s, 45s, 75s)',
                  'Schedule 3 notifications at different times',
                  Icons.format_list_numbered,
                  Colors.purple,
                  _testMultiple,
                ),
                
                _buildTestButton(
                  'TEST 5: Cancel Notification',
                  'Schedule then immediately cancel',
                  Icons.cancel,
                  Colors.red,
                  _testCancel,
                ),
                
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                
                const Text(
                  'ADVANCED TESTS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 8),
                
                _buildTestButton(
                  'TEST 6: App Kill Survival (2m)',
                  'Test if notification survives force closing app',
                  Icons.power_settings_new,
                  Colors.deepOrange,
                  _testAppKillSurvival,
                ),
                
                _buildTestButton(
                  'TEST 7: Reschedule All',
                  'Test bulk rescheduling (simulates boot behavior)',
                  Icons.refresh,
                  Colors.teal,
                  _testRescheduleAll,
                ),
                
                _buildTestButton(
                  'TEST 8: Check Reboot Status',
                  'Check if device was rebooted (needs reschedule)',
                  Icons.restart_alt,
                  Colors.indigo,
                  _testRebootCheck,
                ),
                
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                
                _buildTestButton(
                  'Clear All Test Notifications',
                  'Cancel all scheduled test notifications',
                  Icons.clear_all,
                  Colors.grey,
                  _clearAllTests,
                ),
              ],
            ),
          ),
          
          // Log Display
          _buildLogDisplay(),
        ],
      ),
    );
  }
  
  Widget _buildStatusCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      color: _isInitialized ? Colors.green.shade50 : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isInitialized ? Icons.check_circle : Icons.pending,
                  color: _isInitialized ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  _isInitialized ? 'System Ready' : 'Initializing...',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatusRow(
              'Exact Alarms',
              _canScheduleExact ? 'Enabled ✅' : 'Disabled (using inexact) ⚠️',
              _canScheduleExact ? Colors.green : Colors.orange,
            ),
            _buildStatusRow(
              'Active Scheduled',
              '$_scheduledCount notifications',
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  
  Widget _buildTestButton(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.play_arrow),
        onTap: _isInitialized ? onPressed : null,
      ),
    );
  }
  
  Widget _buildLogDisplay() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black87,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: const Row(
              children: [
                Icon(Icons.terminal, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Test Logs (Live)',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Icon(Icons.fiber_manual_record, color: Colors.green, size: 12),
              ],
            ),
          ),
          Expanded(
            child: _testLogs.isEmpty
                ? const Center(
                    child: Text(
                      'No logs yet. Run a test to see output.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(8),
                    itemCount: _testLogs.length,
                    itemBuilder: (context, index) {
                      final log = _testLogs[index];
                      Color logColor = Colors.white;
                      
                      if (log.contains('✅')) logColor = Colors.green;
                      if (log.contains('❌')) logColor = Colors.red;
                      if (log.contains('⚠️')) logColor = Colors.orange;
                      if (log.contains('🧪')) logColor = Colors.cyan;
                      if (log.contains('📱')) logColor = Colors.yellow;
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          log,
                          style: TextStyle(
                            color: logColor,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
