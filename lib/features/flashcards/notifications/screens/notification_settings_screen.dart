import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/core.dart';
import '../../../../core/services/background_service.dart';
import '../../../../core/utils/notification_migration_helper.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  final BackgroundService _backgroundService = BackgroundService();
  
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  List<int> _selectedDays = [1, 2, 3, 4, 5, 6, 7];
  bool _notificationsEnabled = false;
  bool _dailyRemindersEnabled = false;
  bool _overdueRemindersEnabled = false;
  bool _streakRemindersEnabled = false;
  bool _isLoading = true;
  Map<String, dynamic> _notificationStats = {};

  final List<String> _dayNames = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    try {
      _notificationsEnabled = await _notificationService.areNotificationsEnabled();
      
      final settings = await _notificationService.getReminderSettings();
      if (settings != null) {
        _selectedTime = TimeOfDay(
          hour: settings['hour'] as int,
          minute: settings['minute'] as int,
        );
        _selectedDays = (settings['days'] as List<String>).map(int.parse).toList();
        _dailyRemindersEnabled = true;
      }
      
      final prefs = await SharedPreferences.getInstance();
      _overdueRemindersEnabled = prefs.getBool('overdue_reminders_enabled') ?? true;
      _streakRemindersEnabled = prefs.getBool('streak_reminders_enabled') ?? true;
      
      _notificationStats = await _backgroundService.getNotificationStats();
    } catch (e) {
      print('Error loading notification settings: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_dailyRemindersEnabled) {
        await prefs.setInt('reminder_hour', _selectedTime.hour);
        await prefs.setInt('reminder_minute', _selectedTime.minute);
        await prefs.setStringList('reminder_days', _selectedDays.map((d) => d.toString()).toList());
        
        final now = DateTime.now();
        DateTime? nextReminder;
        
        for (int daysAhead = 0; daysAhead < 8; daysAhead++) {
          final checkDate = now.add(Duration(days: daysAhead));
          final dayOfWeek = checkDate.weekday;
          
          if (_selectedDays.contains(dayOfWeek)) {
            var scheduledTime = DateTime(
              checkDate.year,
              checkDate.month,
              checkDate.day,
              _selectedTime.hour,
              _selectedTime.minute,
            );
            
            if (daysAhead == 0 && scheduledTime.isAfter(now)) {
              nextReminder = scheduledTime;
              break;
            } else if (daysAhead > 0) {
              nextReminder = scheduledTime;
              break;
            }
          }
        }
        
        if (nextReminder != null) {
          final success = await NotificationMigrationHelper.scheduleDailyStudyReminder(
            scheduledTime: nextReminder,
            message: 'Time for your daily study session! 📚',
          );
          
          if (!success) throw Exception('Failed to schedule reminder');
          print('✅ Scheduled daily reminder for: $nextReminder');
        }
      } else {
        await NotificationMigrationHelper.cancelDailyReminder();
        await prefs.remove('reminder_hour');
        await prefs.remove('reminder_minute');
        await prefs.remove('reminder_days');
      }

      await prefs.setBool('overdue_reminders_enabled', _overdueRemindersEnabled);
      await prefs.setBool('streak_reminders_enabled', _streakRemindersEnabled);

      _notificationStats = await _backgroundService.getNotificationStats();

      if (mounted) {
        SnackbarUtils.showSuccessSnackbar(context, 'Settings saved successfully!');
      }
    } catch (e) {
      print('Error saving settings: $e');
      if (mounted) {
        SnackbarUtils.showErrorSnackbar(context, 'Error saving settings');
      }
    }
  }

  Future<void> _requestPermissions() async {
    final granted = await _notificationService.requestNotificationPermissions();
    setState(() => _notificationsEnabled = granted);
    
    if (!granted && mounted) {
      SnackbarUtils.showWarningSnackbar(
        context,
        'Please enable notifications in device settings',
      );
    }
    
    _notificationStats = await _backgroundService.getNotificationStats();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
      await _saveSettings();
    }
  }

  void _toggleDay(int day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        if (_selectedDays.length > 1) {
          _selectedDays.remove(day);
        }
      } else {
        _selectedDays.add(day);
      }
      _selectedDays.sort();
    });
    _saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notification Settings',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSettings,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Permission Status Card
                  _buildPermissionCard(),
                  const SizedBox(height: 16),

                  // Stats Card
                  if (_notificationStats.isNotEmpty) ...[
                    _buildStatsCard(),
                    const SizedBox(height: 16),
                  ],

                  // Daily Reminders
                  _buildDailyRemindersCard(),
                  const SizedBox(height: 16),

                  // Overdue Reminders
                  _buildToggleCard(
                    icon: Icons.warning_amber_rounded,
                    iconColor: Colors.orange,
                    title: 'Overdue Cards',
                    subtitle: 'Notify when cards need review',
                    value: _overdueRemindersEnabled,
                    onChanged: _notificationsEnabled
                        ? (value) {
                            setState(() => _overdueRemindersEnabled = value);
                            _saveSettings();
                          }
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Streak Reminders
                  _buildToggleCard(
                    icon: Icons.local_fire_department,
                    iconColor: Colors.deepOrange,
                    title: 'Study Streaks',
                    subtitle: 'Celebrate your study consistency',
                    value: _streakRemindersEnabled,
                    onChanged: _notificationsEnabled
                        ? (value) {
                            setState(() => _streakRemindersEnabled = value);
                            _saveSettings();
                          }
                        : null,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPermissionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _notificationsEnabled
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _notificationsEnabled
                        ? Icons.notifications_active
                        : Icons.notifications_off,
                    color: _notificationsEnabled ? Colors.green : Colors.red,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _notificationsEnabled ? 'Enabled' : 'Disabled',
                        style: TextStyle(
                          fontSize: 14,
                          color: _notificationsEnabled
                              ? Colors.green
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_notificationsEnabled)
                  ElevatedButton(
                    onPressed: _requestPermissions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Enable'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics_outlined, color: Colors.blue[700], size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Your Progress',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.local_fire_department,
                    label: 'Streak',
                    value: '${_notificationStats['currentStreak'] ?? 0} days',
                    color: Colors.deepOrange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.calendar_today,
                    label: 'Last Study',
                    value: _notificationStats['lastStudyDate'] != null
                        ? _formatDate(_notificationStats['lastStudyDate'])
                        : 'Never',
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyRemindersCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.schedule, color: Colors.blue, size: 24),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Daily Reminders',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                Switch(
                  value: _dailyRemindersEnabled,
                  onChanged: _notificationsEnabled
                      ? (value) {
                          setState(() => _dailyRemindersEnabled = value);
                          _saveSettings();
                        }
                      : null,
                ),
              ],
            ),
            if (_dailyRemindersEnabled) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              
              // Time Selection
              InkWell(
                onTap: _selectTime,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.grey[700]),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reminder Time',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Icon(Icons.chevron_right, color: Colors.grey[400]),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Days Selection
              Text(
                'Reminder Days',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(7, (index) {
                  final day = index + 1;
                  final isSelected = _selectedDays.contains(day);
                  
                  return InkWell(
                    onTap: () => _toggleDay(day),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _dayNames[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildToggleCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool)? onChanged,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '${difference}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
